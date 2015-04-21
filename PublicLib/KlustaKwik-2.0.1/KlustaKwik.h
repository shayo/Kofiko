#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdarg.h>
#include <iostream>
#include <fstream>
using namespace std;
#include "param.h"
#include "Array.h"
/*
#include <stdio.h>
#include <stdlib.h>
#include "param.h"
#include "Array.h"
#include <fstream.h>
#include <iostream.h>
#include <math.h>
#include <time.h>
#include <stdarg.h>
*/

class KK {
public:
	// FUNCTIONS
    void AllocateArrays();
	void LoadData();
	float Penalty(int n);
	float ComputeScore();
	void MStep();
	void EStep();
	void CStep();
	void ConsiderDeletion();
    void LoadClu(char *StartCluFile);
    int TrySplits();
	float CEM(char *CluFile, int recurse, int InitRand);
	float Cluster(char *CluFile);
    void Reindex();
public:
	// VARIABLES
	int nDims, nDims2; // nDims2 is nDims squared
	int nStartingClusters; // total # starting clusters, including clu 0, the noise cluster.
    int nClustersAlive; // nClustersAlive is total number with points in, excluding noise cluster
	int nPoints;
    int NoisePoint; // number of fake points always in noise cluster to ensure noise weight>0
	int FullStep; // Indicates that the next E-step should be a full step (no time saving)
	float penaltyMix;		// amount of BIC to use for penalty, must be between 0 and 1
	Array<float> Data; // Data[p*nDims + d] = Input data for poitn p, dimension d
	Array<float> Weight; // Weight[c] = Class weight for class c
	Array<float> Mean; // Mean[c*nDims + d] = cluster mean for cluster c in dimension d
	Array<float> Cov; // Cov[c*nDims*nDims + i*nDims + j] = Covariance for cluster C, entry i,j
					// NB covariances are stored in upper triangle (j>=i)
	Array<float> LogP; // LogP[p*MaxClusters + c] = minus log likelihood for point p in cluster c
	Array<int> Class; // Class[p] = best cluster for point p
	Array<int> OldClass; // Class[p] = previous cluster for point p
	Array<int> Class2; // Class[p] = second best cluster for point p
	Array<int> BestClass; // BestClass = best classification yet achieved
	Array<int> ClassAlive; // contains 1 if the class is still alive - otherwise 0
    Array<int> AliveIndex; // a list of the alive classes to iterate over
};

void SetupParams(int argc, char **argv);
void Error(char *fmt, ...);
void Output(char *fmt, ...);
int irand(int min, int max);
FILE *fopen_safe(char *fname, char *mode);
void MatPrint(FILE *fp, float *Mat, int nRows, int nCols);
int Cholesky(float *m_In, float *m_Out, int D);
void TriSolve(float *M, float *x, float *Out, int D);
// void main(int argc, char **argv);


void SaveOutput(Array<int> &OutputClass);
