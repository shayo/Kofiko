// KlustaKwik.C
//
// Fast clustering using the CEM algorithm.

#include "KlustaKwik.h"
#define M_PI 3.14159265358979323846
#define STRLEN 10000
// PARAMETERS
int MinClusters = 20; // Min and MaxClusters includes cluster 1, the noise cluster
int MaxClusters = 30;
int MaxPossibleClusters = 100; // splitting can't make it exceed this
int nStarts = 1; // number of times to start count from each number of clusters
int RandomSeed = 1;
//char Debug = 0;
int Verbose = 1;
//int DistDump = 0;
float DistThresh = (float)log(1000.0); // Points with at least this much difference from
							// the best do not get E-step recalculated - and that's most of them
int FullStepEvery = 20;		// But there is always a full estep this every this many iterations
float ChangedThresh = (float).05;	// Or if at least this fraction of points changed class last time
//char Log = 0;
char Screen =0;	// log output to screen
int MaxIter = 500; // max interations
int SplitEvery=40; // allow cluster splitting every this many iterations
float PenaltyMix = 1.0;	// amount of BIC to use as penalty, rather than AIC
int Subset = 1; // do clustering on this fraction of points, then generalize to whole data set

// GLOBAL VARIABLES
//FILE *logfp, *Distfp;
float HugeScore = (float)1e32;

void SetupParams(int nrhs, const mxArray *prhs[]) {
	// PARAMETER DEFINITIONS GO HERE
	// First two paramers are feature matrix and initial cluster assignment (or emptry)
	int NumParams = nrhs-2;
	if (NumParams % 2 != 0)
		mexErrMsgTxt("Number of parameters should be even (i.e., param name, param value)");

	char buf[STRLEN];

	int ActualNumParam = NumParams/2;
	for (int paramiter=0;paramiter<ActualNumParam;paramiter++) {
			int strlen = (int) mxGetNumberOfElements(prhs[2+paramiter])+1;
			mxGetString(prhs[2+paramiter*2], buf, STRLEN);

		if (_strcmpi(buf, "MinClusters") == 0){
				MinClusters = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
				Output("Setting MinClusters to %d\n",MinClusters);
		} else if (_strcmpi(buf, "MaxClusters") == 0) {
			MaxClusters = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting MaxClusters to %d\n",MaxClusters);
		} else if (_strcmpi(buf, "MaxPossibleClusters") == 0) {
			MaxPossibleClusters = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting MaxPossibleClusters to %d\n",MaxPossibleClusters);
		} else if (_strcmpi(buf, "nStarts") == 0) {
			nStarts = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting nStarts to %d\n",nStarts);
		} else if (_strcmpi(buf, "RandomSeed") == 0) {
			RandomSeed = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting RandomSeed to %d\n",RandomSeed);
		} else if (_strcmpi(buf, "Verbose") == 0) {
			Verbose = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting Verbose to %d\n",Verbose);
		} else if (_strcmpi(buf, "DistThresh") == 0) {
			DistThresh = (float) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting DistThresh to %f\n",DistThresh);
		} else if (_strcmpi(buf, "FullStepEvery") == 0) {
			FullStepEvery = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting FullStepEvery to %d\n",FullStepEvery);
		} else if (_strcmpi(buf, "ChangedThresh") == 0) {
			ChangedThresh = (float) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting ChangedThresh to %f\n",ChangedThresh);
		} else if (_strcmpi(buf, "Screen") == 0) {
			Screen = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting Screen to %d\n",Screen);
		} else if (_strcmpi(buf, "MaxIter") == 0) {
			MaxIter = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting MaxIter to %d\n",MaxIter);
		} else if (_strcmpi(buf, "SplitEvery") == 0) {
			SplitEvery = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting SplitEvery to %d\n",SplitEvery);
		} else if (_strcmpi(buf, "PenaltyMix") == 0) {
			PenaltyMix = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting PenaltyMix to %d\n",PenaltyMix);
		} else if (_strcmpi(buf, "Subset") == 0) {
			Subset = (int) *(double*)mxGetPr(prhs[2+paramiter*2+1]);
			Output("Setting Subset to %d\n",Subset);
		} else
			mexErrMsgTxt("Unknown paramter");
	


	}
	/*
	INT_PARAM(MinClusters);
	INT_PARAM(MaxClusters);
	INT_PARAM(MaxPossibleClusters);
	INT_PARAM(nStarts);
	INT_PARAM(RandomSeed);
	INT_PARAM(Verbose);
	FLOAT_PARAM(DistThresh);
	INT_PARAM(FullStepEvery);
	FLOAT_PARAM(ChangedThresh);
	BOOLEAN_PARAM(Screen);
	INT_PARAM(MaxIter);
	INT_PARAM(SplitEvery);
	FLOAT_PARAM(PenaltyMix);
	INT_PARAM(Subset);
	*/
}

// Print an error message and abort
void Error(char *fmt, ...) {
	va_list arg;

	va_start(arg, fmt);
	vfprintf(stderr, fmt, arg);
	va_end(arg);

	abort();
}

// Write to screen and log file
void Output(char *fmt, ...) {
	va_list arg;
	char str[STRLEN];
	if (!Screen ) return;
	va_start(arg, fmt);
	vsnprintf(str,STRLEN,fmt,arg);
	va_end(arg);

	if (Screen) mexPrintf("%s", str);
	//if (Log) fprintf(logfp, "%s", str);

}

/* integer random number between min and max*/
int irand(int min, int max)
{
	return (rand() % (max - min + 1) + min);
}


// Print a matrix
void MatPrint(FILE *fp, float *Mat, int nRows, int nCols) {
	int i, j;

	for (i=0; i<nRows; i++) {
		for (j=0; j<nCols; j++) {
			fprintf(fp, "%.5g ", Mat[i*nCols + j]);
		}
		fprintf(fp, "\n");
	}
}

// write output to .clu file - with 1 added to cluster numbers, and empties removed.
void SaveOutput(Array<int> &OutputClass, double* OutputArray) {
	int p, c;
	int MaxClass = 0;
	Array<int> NotEmpty(MaxPossibleClusters);
	Array<int> NewLabel(MaxPossibleClusters);

	// find non-empty clusters
	for(c=0;c<MaxPossibleClusters;c++) NewLabel[c] = NotEmpty[c] = 0;
	for(p=0; p<OutputClass.size(); p++) NotEmpty[OutputClass[p]] = 1;

	// make new cluster labels so we don't have empty ones
    NewLabel[0] = 1;
	MaxClass = 1;
	for(c=1;c<MaxPossibleClusters;c++) {
		if (NotEmpty[c]) {
			MaxClass++;
			NewLabel[c] = MaxClass;
		}
	}

	// print file
	//sprintf(fname, "%s.clu.%d", FileBase, ElecNo);
	//fp = fopen_safe(fname, "w");

	//fprintf(fp, "%d\n", MaxClass);
	int q = 0;
	for (p=0; p<OutputClass.size(); p++) 
		OutputArray[q++] = (int)NewLabel[OutputClass[p]];

	//		fprintf(fp, "%d\n", NewLabel[OutputClass[p]]);
	//fclose(fp);
}

// Cholesky Decomposition
// In provides upper triangle of input matrix (In[i*D + j] >0 if j>=i);
// which is the top half of a symmetric matrix
// Out provides lower triange of output matrix (Out[i*D + j] >0 if j<=i);
// such that Out' * Out = In.
// D is number of dimensions
//
// returns 0 if OK, returns 1 if matrix is not positive definite
int Cholesky(float *m_In, float *m_Out, int D) {
	int i, j, k;
	float sum;

	// go from float * inputs to Array<float>'s
	// probably unnecessary if I knew C++ better
	Array<float> In(m_In, D*D);
	Array<float> Out(D*D);

	// empty output array
	for (i=0; i<D*D; i++) Out[i] = 0;

	// main bit
	for (i=0; i<D; i++) {
		for (j=i; j<D; j++) {	// j>=i
			sum = In[i*D + j];

			for (k=i-1; k>=0; k--) sum -= Out[i*D + k] * Out[j*D + k]; // i,j >= k
			if (i==j) {
				if (sum <=0) return(1); // Cholesky decomposition has failed
				Out[i*D + i] = (float)sqrt(sum);
			}
			else {
				Out[j*D + i] = sum/Out[i*D + i];
			}
		}
	}

	// copy output to output array - it sucks i know
	for(i=0; i<D*D; i++) m_Out[i] = Out[i];

	return 0; // for sucess
}

// Solve a set of linear equations M*Out = x.
// Where M is lower triangular (M[i*D + j] >0 if j>=i);
// D is number of dimensions
void TriSolve(float *M, float *x, float *Out, int D) {
	int i, j;
	float sum;

	for(i=0; i<D; i++) {
		sum = x[i];
		for (j=i-1; j>=0; j--) sum -= M[i*D + j] * Out[j]; // j<i

//		for (pM=M + i*D + i-1, pOut = Out + i-1; pOut>=Out; pM--, pOut--) sum -= *pM * *pOut;
		Out[i] = sum / M[i*D + i];
	}
}

// Sets storage for KK class.  Needs to have nDims and nPoints defined
void KK::AllocateArrays() {

	nDims2 = nDims*nDims;
	NoisePoint = 1;

	// Set sizes for arrays
	Data.SetSize(nPoints * nDims);
	Weight.SetSize(MaxPossibleClusters);
	Mean.SetSize(MaxPossibleClusters*nDims);
	Cov.SetSize(MaxPossibleClusters*nDims2);
	LogP.SetSize(MaxPossibleClusters*nPoints);
	Class.SetSize(nPoints);
	OldClass.SetSize(nPoints);
	Class2.SetSize(nPoints);
	BestClass.SetSize(nPoints);
	ClassAlive.SetSize(MaxPossibleClusters);
	AliveIndex.SetSize(MaxPossibleClusters);
}

// recompute index of alive clusters (including 0, the noise cluster)
// should be called after anything that changes ClassAlive
void KK::Reindex() {
    int c;

    AliveIndex[0] = 0;
    nClustersAlive=1;
    for(c=1;c<MaxPossibleClusters;c++) {
        if (ClassAlive[c]) {
            AliveIndex[nClustersAlive] = c;
            nClustersAlive++;
        }
    }
}

// Loads in Fet file.  Also allocates storage for other arrays
void KK::LoadData(const mxArray *FeaturesMatrix) {
	int p, i;
	float val;
	float max, min;

	// open file

	//sprintf(fname, "%s.fet.%d", FileBase, ElecNo);
	//fp = fopen_safe(fname, "r");

	const int *sz = mxGetDimensions(FeaturesMatrix);
	 nPoints = sz[1];
	 nDims = sz[0];
	double *InputArray = mxGetPr(FeaturesMatrix);

    AllocateArrays();

	// load data
	for (int k=0;k<nDims*nPoints;k++)
		Data[k] = (float)InputArray[k];

	// normalize data so that range is 0 to 1: This is useful in case of v. large inputs
	for(i=0; i<nDims; i++) {

		//calculate min and max
		min = HugeScore; max=-HugeScore;
		for(p=0; p<nPoints; p++) {
			val = Data[p*nDims + i];
			if (val > max) max = val;
			if (val < min) min = val;
		}

		// now normalize
		for(p=0; p<nPoints; p++) Data[p*nDims+i] = (Data[p*nDims+i] - min) / (max-min);
	}

	Output("Loaded %d data points of dimension %d.\n", nPoints, nDims);
}



// Penalty(nAlive) returns the complexity penalty for that many clusters
// bearing in mind that cluster 0 has no free params except p.
float KK::Penalty(int n) {
		int nParams;

        if(n==1) return 0;

		 nParams = (nDims*(nDims+1)/2 + nDims + 1)*(n-1); // each has cov, mean, &p

		// Use AIC
		//return nParams*2;

		// BIC is too harsh
		//return nParams*log(nPoints)/2;

		// return mixture of AIC and BIC
		return (float)(1.0 - penaltyMix) * nParams * 2 + penaltyMix * (nParams * log((float)nPoints)/2);
}

// M-step: Calculate mean, cov, and weight for each living class
// also deletes any classes with less points than nDim
void KK::MStep() {
	int p, c, cc, i, j;
	Array<int> nClassMembers(MaxPossibleClusters);
	Array<float> Vec2Mean(nDims);

	// clear arrays
	for(c=0; c<MaxPossibleClusters; c++) {
		nClassMembers[c] = 0;
		for(i=0; i<nDims; i++) Mean[c*nDims + i] = 0;
		for(i=0; i<nDims; i++) for(j=i; j<nDims; j++) {
			Cov[c*nDims2 + i*nDims + j] = 0;
		}
	}

	// Accumulate total number of points in each class
	for (p=0; p<nPoints; p++) nClassMembers[Class[p]]++;

    // check for any dead classes
    for (cc=0; cc<nClustersAlive; cc++) {
        c = AliveIndex[cc];
        if (c>0 && nClassMembers[c]<=nDims) {
            ClassAlive[c]=0;
        	Output("Deleted class %d: not enough members\n", c);
        }
    }
    Reindex();


	// Normalize by total number of points to give class weight
	// Also check for dead classes
    for (cc=0; cc<nClustersAlive; cc++) {
        c = AliveIndex[cc];
        // add "noise point" to make sure Weight for noise cluster never gets to zero
        if(c==0) {
      		Weight[c] = ((float)nClassMembers[c]+NoisePoint) / (nPoints+NoisePoint);
        } else {
        	Weight[c] = ((float)nClassMembers[c]) / (nPoints+NoisePoint);
        }
	}
    Reindex();

	// Accumulate sums for mean caculation
	for (p=0; p<nPoints; p++) {
		c = Class[p];
		for(i=0; i<nDims; i++) {
			Mean[c*nDims + i] += Data[p*nDims + i];
		}
	}

	// and normalize
    for (cc=0; cc<nClustersAlive; cc++) {
        c = AliveIndex[cc];
		for (i=0; i<nDims; i++) Mean[c*nDims + i] /= nClassMembers[c];
	}

	// Accumulate sums for covariance calculation
	for (p=0; p<nPoints; p++) {

		c = Class[p];

		// calculate distance from mean
		for(i=0; i<nDims; i++) Vec2Mean[i] = Data[p*nDims + i] - Mean[c*nDims + i];

		for(i=0; i<nDims; i++) for(j=i; j<nDims; j++) {
			Cov[c*nDims2 + i*nDims + j] += Vec2Mean[i] * Vec2Mean[j];
		}
	}

	// and normalize
    for (cc=0; cc<nClustersAlive; cc++) {
        c = AliveIndex[cc];
		for(i=0; i<nDims; i++) for(j=i; j<nDims; j++) {
			Cov[c*nDims2 + i*nDims + j] /= (nClassMembers[c]-1);
		}
	}

	// That's it!

	// Diagnostics
	/*
	if (Debug) {
        for (cc=0; cc<nClustersAlive; cc++) {
            c = AliveIndex[cc];
			Output("Class %d - Weight %.2g\n", c, Weight[c]);
			Output("Mean: ");
			MatPrint(stdout, Mean.m_Data + c*nDims, 1, nDims);
			Output("\nCov:\n");
			MatPrint(stdout, Cov.m_Data + c*nDims2, nDims, nDims);
			Output("\n");
		}
	}
	*/
}

// E-step.  Calculate Log Probs for each point to belong to each living class
// will delete a class if covariance matrix is singular
// also counts number of living classes
void KK::EStep() {
	int p, c, cc, i;
	int nSkipped;
	float LogRootDet; // log of square root of covariance determinant
	float Mahal; // Mahalanobis distance of point from cluster center
	Array<float> Chol(nDims2); // to store choleski decomposition
	Array<float> Vec2Mean(nDims); // stores data point minus class mean
	Array<float> Root(nDims); // stores result of Chol*Root = Vec
    float *OptPtrLogP;
    int *OptPtrClass = Class.m_Data;
    int *OptPtrOldClass = OldClass.m_Data;

	nSkipped = 0;

	// start with cluster 0 - uniform distribution over space
	// because we have normalized all dims to 0...1, density will be 1.
	for (p=0; p<nPoints; p++) LogP[p*MaxPossibleClusters + 0] = (float)-log(Weight[0]);

    for (cc=1; cc<nClustersAlive; cc++) {
        c = AliveIndex[cc];

		// calculate cholesky decomposition for class c
		if (Cholesky(Cov.m_Data+c*nDims2, Chol.m_Data, nDims)) {
			// If Cholesky returns 1, it means the matrix is not positive definite.
			// So kill the class.
			Output("Deleting class %d: covariance matrix is	singular\n", c);
			ClassAlive[c] = 0;
			continue;
		}

		// LogRootDet is given by log of product of diagonal elements
		LogRootDet = 0;
		for(i=0; i<nDims; i++) LogRootDet += (float)log(Chol[i*nDims + i]);

		for (p=0; p<nPoints; p++) {
            // optimize for speed ...
            OptPtrLogP = LogP.m_Data + (p*MaxPossibleClusters);

			// to save time -- only recalculate if the last one was close
			if (
				!FullStep
//              Class[p] == OldClass[p]
//				&& LogP[p*MaxPossibleClusters+c] - LogP[p*MaxPossibleClusters+Class[p]] > DistThresh
                && OptPtrClass[p] == OptPtrOldClass[p]
				&& OptPtrLogP[c] - OptPtrLogP[OptPtrClass[p]] > DistThresh
			) {
				nSkipped++;
				continue;
			}

			// Compute Mahalanobis distance
			Mahal = 0;

			// calculate data minus class mean
			for(i=0; i<nDims; i++) Vec2Mean[i] = Data[p*nDims + i] - Mean[c*nDims + i];

			// calculate Root vector - by Chol*Root = Vec2Mean
			TriSolve(Chol.m_Data, Vec2Mean.m_Data, Root.m_Data, nDims);

			// add half of Root vector squared to log p
			for(i=0; i<nDims; i++) Mahal += Root[i]*Root[i];


			// Score is given by Mahal/2 + log RootDet - log weight
//			LogP[p*MaxPossibleClusters + c] = Mahal/2
			OptPtrLogP[c] = Mahal/2
   									+ LogRootDet
									- log(Weight[c])
									+ (float)log(2*M_PI)*nDims/2;

/*			if (Debug) {
				if (p==0) {
					Output("Cholesky\n");
					MatPrint(stdout, Chol.m_Data, nDims, nDims);
					Output("root vector:\n");
					MatPrint(stdout, Root.m_Data, 1, nDims);
					Output("First point's score = %.3g + %.3g - %.3g = %.3g\n", Mahal/2, LogRootDet
					, log(Weight[c]), LogP[p*MaxPossibleClusters + c]);
				}
			}
*/
		}
	}
//	Output("Skipped %d ", nSkipped);

}

// Choose best class for each point (and second best) out of those living
void KK::CStep() {
	int p, c, cc, TopClass, SecondClass;
	float ThisScore, BestScore, SecondScore;

	for (p=0; p<nPoints; p++) {
		OldClass[p] = Class[p];
		BestScore = HugeScore;
		SecondScore = HugeScore;
		TopClass = SecondClass = 0;
        for (cc=0; cc<nClustersAlive; cc++) {
            c = AliveIndex[cc];
        	ThisScore = LogP[p*MaxPossibleClusters + c];
			if (ThisScore < BestScore) {
				SecondClass = TopClass;
				TopClass = c;
				SecondScore = BestScore;
				BestScore = ThisScore;
			}
			else if (ThisScore < SecondScore) {
				SecondClass = c;
				SecondScore = ThisScore;
			}
		}
		Class[p] = TopClass;
		Class2[p] = SecondClass;
	}
}

// Sometimes deleting a cluster will improve the score, when you take into accout
// the BIC. This function sees if this is the case.  It will not delete more than
// one cluster at a time.
void KK::ConsiderDeletion() {

	int c, p, CandidateClass;
	float Loss, DeltaPen;
	Array<float> DeletionLoss(MaxPossibleClusters); // the increase in log P by deleting the cluster

	for(c=1; c<MaxPossibleClusters; c++) {
		if (ClassAlive[c]) DeletionLoss[c] = 0;
		else DeletionLoss[c] = HugeScore; // don't delete classes that are already there
	}

	// compute losses by deleting clusters
	for(p=0; p<nPoints; p++) {
		DeletionLoss[Class[p]] += LogP[p*MaxPossibleClusters + Class2[p]] - LogP[p*MaxPossibleClusters + Class[p]];
	}

	// find class with least to lose
	Loss = HugeScore;
	for(c=1; c<MaxPossibleClusters; c++) {
		if (DeletionLoss[c]<Loss) {
			Loss = DeletionLoss[c];
			CandidateClass = c;
		}
	}

	// what is the change in penalty?
	DeltaPen = Penalty(nClustersAlive) - Penalty(nClustersAlive-1);

	//Output("cand Class %d would lose %f gain is %f\n", CandidateClass, Loss, DeltaPen);
	// is it worth it?
	if (Loss<DeltaPen) {
		Output("Deleting Class %d. Lose %f but Gain %f\n", CandidateClass, Loss, DeltaPen);
		// set it to dead
		ClassAlive[CandidateClass] = 0;

		// re-allocate all of its points
		for(p=0;p<nPoints; p++) if(Class[p]==CandidateClass) Class[p] = Class2[p];
	}
    Reindex();
}


// LoadClu(CluFile)
void KK::LoadClu(const mxArray *InputClass) {
    int p, c;

	const int *sz = mxGetDimensions(InputClass);
	int nClustersAlive = MAX(sz[0], sz[1]);
	double *InputArray = mxGetPr(InputClass);

    nClustersAlive = nStartingClusters;// -1;
    for(c=0; c<MaxPossibleClusters; c++) ClassAlive[c]=(c<nStartingClusters);

    for(p=0; p<nPoints; p++) {
         Class[p] = (int)InputArray[p]-1;
    }
}

// for each cluster, try to split it in two.  if that improves the score, do it.
// returns 1 if split was successful
int KK::TrySplits() {
    int i, c, cc, c2, p, p2, d, DidSplit = 0;
    float Score, NewScore, UnsplitScore, SplitScore;
    int UnusedCluster;
    KK K2; // second KK structure for sub-clustering
    KK K3; // third one for comparison

    if(nClustersAlive>=MaxPossibleClusters-1) {
        Output("Won't try splitting - already at maximum number of clusters\n");
        return 0;
    }

    // set up K3
    K3.nDims = nDims; K3.nPoints = nPoints;
    K3.penaltyMix = PenaltyMix;
    K3.AllocateArrays();
    for(i=0; i<nDims*nPoints; i++) K3.Data[i] = Data[i];

    Score = ComputeScore();

    // loop thu clusters, trying to split
    for (cc=1; cc<nClustersAlive; cc++) {
        c = AliveIndex[cc];

        // set up K2 strucutre to contain points of this cluster only

        // count number of points and allocate memory
        K2.nPoints = 0;
        K2.penaltyMix = PenaltyMix;
        for(p=0; p<nPoints; p++) if(Class[p]==c) K2.nPoints++;
        if(K2.nPoints==0) continue;
        K2.nDims = nDims;
        K2.AllocateArrays();
        K2.NoisePoint = 0;

        // put data into K2
        p2=0;
        for(p=0; p<nPoints; p++) if(Class[p]==c) {
            for(d=0; d<nDims; d++) K2.Data[p2*nDims + d] = Data[p*nDims + d];
            p2++;
        }

        // find an unused cluster
        UnusedCluster = -1;
        for(c2=1; c2<MaxPossibleClusters; c2++) {
             if (!ClassAlive[c2]) {
                 UnusedCluster = c2;
                 break;
             }
        }
        if (UnusedCluster==-1) {
            Output("No free clusters, abandoning split");
            return DidSplit;
        }

        // do it
        if (Verbose>=1) Output("Trying to split cluster %d (%d points) \n", c, K2.nPoints);
        K2.nStartingClusters=2; // (2 = 1 clusters + 1 unused noise cluster)
        UnsplitScore = K2.CEM(NULL, 0, 1);
        K2.nStartingClusters=3; // (3 = 2 clusters + 1 unused noise cluster)
        SplitScore = K2.CEM(NULL, 0, 1);

        // Fix by Michaël Zugaro: replace next line with following two lines
        // if(SplitScore<UnsplitScore) {
        if(K2.nClustersAlive<2) Output("Split failed - leaving alone\n");
        if(SplitScore<UnsplitScore&&K2.nClustersAlive>=2) {
            // will splitting improve the score in the whole data set?

            // assign clusters to K3
            for(c2=0; c2<MaxPossibleClusters; c2++) K3.ClassAlive[c2]=0;
            p2 = 0;
            for(p=0; p<nPoints; p++) {
                if(Class[p]==c) {
                    if(K2.Class[p2]==1) K3.Class[p] = c;
                    else if(K2.Class[p2]==2) K3.Class[p] = UnusedCluster;
                    else Error("split should only produce 2 clusters");
                    p2++;
                } else K3.Class[p] = Class[p];
                K3.ClassAlive[K3.Class[p]] = 1;
            }
            K3.Reindex();

            // compute scores
            K3.MStep();
            K3.EStep();
            NewScore = K3.ComputeScore();
            Output("Splitting cluster %d changes total score from %f to %f\n", c, Score, NewScore);

            if (NewScore<Score) {
                DidSplit = 1;
                Output("So it's getting split into cluster %d.\n", UnusedCluster);
                // so put clusters from K3 back into main KK struct (K1)
                for(c2=0; c2<MaxPossibleClusters; c2++) ClassAlive[c2] = K3.ClassAlive[c2];
                for(p=0; p<nPoints; p++) Class[p] = K3.Class[p];
            } else {
                Output("So it's not getting split.\n");
            }
        }
    }
    return DidSplit;
}

// ComputeScore() - computes total score.  Requires M, E, and C steps to have been run
float KK::ComputeScore() {
    int p;

    float Score = Penalty(nClustersAlive);
    for(p=0; p<nPoints; p++) {
        Score += LogP[p*MaxPossibleClusters + Class[p]];
		// Output("point %d: cumulative score %f\n", p, Score);
    }

	/*
	if (Debug) {
		int c, cc;
		float tScore;
		for(cc=0; cc<nClustersAlive; cc++) {
			c = AliveIndex[cc];
			tScore = 0;
			for(p=0; p<nPoints; p++) if(Class[p]==c) tScore += LogP[p*MaxPossibleClusters + Class[p]];
			Output("class %d has subscore %f\n", c, tScore);
		}
	}
	*/

    return Score;
}

// CEM(StartFile) - Does a whole CEM algorithm from a random start
// optional start file loads this cluster file to start iteration
// if Recurse is 0, it will not try and split.
// if InitRand is 0, use cluster assignments already in structure
float KK::CEM(const mxArray *InputClass/*= NULL*/, int Recurse /*=1*/, int InitRand /*=1*/)  {
	int p, c;
	int nChanged;
	int Iter;
	Array<int> OldClass(nPoints);
	float Score = HugeScore, OldScore;
	int LastStepFull; // stores whether the last step was a full one
    int DidSplit;

    if (InputClass!= NULL) LoadClu(InputClass);
	else if (InitRand) {
        // initialize data to random
        if (nStartingClusters>1)
    	    for(p=0; p<nPoints; p++) Class[p] = irand(1, nStartingClusters-1);
        else
            for(p=0; p<nPoints; p++) Class[p] = 0;

		for(c=0; c<MaxPossibleClusters; c++) ClassAlive[c] = (c<nStartingClusters);
    }

	// set all clases to alive
    Reindex();

	// main loop
	Iter = 0;
	FullStep = 1;
	do {
		// Store old classifications
		for(p=0; p<nPoints; p++) OldClass[p] = Class[p];

		// M-step - calculate class weights, means, and covariance matrices for each class
		MStep();

		// E-step - calculate scores for each point to belong to each class
		EStep();

		// dump distances if required

		//if (DistDump) MatPrint(Distfp, LogP.m_Data, DistDump, MaxPossibleClusters);

		// C-step - choose best class for each
		CStep();

		// Would deleting any classes improve things?
		if(Recurse) ConsiderDeletion();

		// Calculate number changed
		nChanged = 0;
		for(p=0; p<nPoints; p++) nChanged += (OldClass[p] != Class[p]);

		// Calculate score
		OldScore = Score;
		Score = ComputeScore();

		if(Verbose>=1) {
            if(Recurse==0) Output("\t");
            Output("Iteration %d%c: %d clusters Score %.7g nChanged %d\n",
			    Iter, FullStep ? 'F' : 'Q', nClustersAlive, Score, nChanged);
        }

		Iter++;

		/*
		if (Debug) {
			for(p=0;p<nPoints;p++) BestClass[p] = Class[p];
			SaveOutput(BestClass);
			Output("Press return");
			getchar();
		}*/

		// Next step a full step?
		LastStepFull = FullStep;
		FullStep = (
						nChanged>ChangedThresh*nPoints
						|| nChanged == 0
						|| Iter%FullStepEvery==0
					//	|| Score > OldScore Doesn't help!
					//	Score decreases are not because of quick steps!
					) ;
		if (Iter>MaxIter) {
			Output("Maximum iterations exceeded\n");
			break;
		}

        // try splitting
        if ((Recurse && SplitEvery>0) && (Iter%SplitEvery==SplitEvery-1 || (nChanged==0 && LastStepFull))) {
            DidSplit = TrySplits();
        } else DidSplit = 0;

	} while (nChanged > 0 || !LastStepFull || DidSplit);

	//if (DistDump) fprintf(Distfp, "\n");

	return Score;
}

// does the two-step clustering algorithm:
// first make a subset of the data, to SubPoints points
// then run CEM on this
// then use these clusters to do a CEM on the full data
float KK::Cluster() {
	KK KKSub;
	int i, d, p;
	//float StepSize; // for resampling
	int sPoints; // number of points to subset to

	if (Subset<=1) { // don't subset
		Output("--- Clustering full data set of %d points ---\n", nPoints);
		return CEM(NULL, 1, 1);
	} else { // run on a subset of points

		sPoints = nPoints/Subset; // number of subset points - integer division will round down

		// set up KKSub object
		KKSub.nDims = nDims;
		KKSub.nPoints = sPoints;
		KKSub.penaltyMix = PenaltyMix;
		KKSub.nStartingClusters = nStartingClusters;
		KKSub.AllocateArrays();

		// fill KKSub with a subset of SubPoints from full data set.
		for (i=0; i<sPoints; i++) {
			// choose point to include, evenly spaced plus a random offset
			p= Subset*i + irand(0,Subset-1);

			// copy data
			for (d=0; d<nDims; d++) KKSub.Data[i*nDims + d] = Data[p*nDims + d];
		}

		// run CEM algorithm on KKSub
		Output("--- Running on subset of %d points ---\n", sPoints);
		KKSub.CEM(NULL, 1, 1);

		// now copy cluster shapes from KKSub to main KK
		Weight = KKSub.Weight;
		Mean = KKSub.Mean;
		Cov = KKSub.Cov;
		ClassAlive = KKSub.ClassAlive;
		nClustersAlive = KKSub.nClustersAlive;
		AliveIndex = KKSub.AliveIndex;

		// Run E and C steps on full data set
		Output("--- Evaluating fit on full set of %d points ---\n", nPoints);
		EStep();
		CStep();

		// compute score on full data set and leave
		return ComputeScore();
	}
}


void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
	float Score;
	float BestScore = HugeScore;
	int p, i;
	SetupParams(nrhs,prhs);

	clock_t Clock0;
	KK K1; // main KK class, for all data
	K1.penaltyMix = PenaltyMix;

	Clock0 = clock(); // start timer

	K1.LoadData(prhs[0]); // load .fet file

	mwSize     dim1[2] = {1,K1.nPoints};
	plhs[0] = mxCreateNumericArray(2, dim1, mxDOUBLE_CLASS, mxREAL);
	double *OutputArray = mxGetPr(plhs[0]);

	// Seed random number generator
	srand(RandomSeed);

	// open distance dump file if required
	//if (DistDump) Distfp = fopen("DISTDUMP", "w");

    // start with provided file, if required

	if (!mxIsEmpty(prhs[1])) {
        Output("Starting from existing clusters \n");
        BestScore = K1.CEM(prhs[1], 1, 1);
		Output("%d->%d Clusters: Score %f\n\n", K1.nStartingClusters, K1.nClustersAlive, BestScore);
		for(p=0; p<K1.nPoints; p++) K1.BestClass[p] = K1.Class[p];
		SaveOutput(K1.BestClass, OutputArray);
    }


	// loop through numbers of clusters ...
	for(K1.nStartingClusters=MinClusters; K1.nStartingClusters<=MaxClusters; K1.nStartingClusters++) for(i=0; i<nStarts; i++) {
		// do CEM iteration
        Output("Starting from %d clusters...\n", K1.nStartingClusters);
		Score = K1.Cluster();

		Output("%d->%d Clusters: Score %f, best is %f\n", K1.nStartingClusters, K1.nClustersAlive, Score, BestScore);

		if (Score < BestScore) {
			Output("THE BEST YET!\n");
			// New best classification found
			BestScore = Score;
			for(p=0; p<K1.nPoints; p++) K1.BestClass[p] = K1.Class[p];
			SaveOutput(K1.BestClass, OutputArray);
		}
		Output("\n");
	}

	SaveOutput(K1.BestClass, OutputArray);

	Output("That took %f seconds.\n", (clock()-Clock0)/(float) CLOCKS_PER_SEC);

	//if (DistDump) fclose(Distfp);

}


