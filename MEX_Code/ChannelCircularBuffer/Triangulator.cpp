#include <math.h>
#include <vector>

/*!
**
** Copyright (c) 2009 by John W. Ratcliff mailto:jratcliffscarab@gmail.com
**
** Portions of this source has been released with the PhysXViewer application, as well as
** Rocket, CreateDynamics, ODF, and as a number of sample code snippets.
**
** If you find this code useful or you are feeling particularily generous I would
** ask that you please go to http://www.amillionpixels.us and make a donation
** to Troy DeMolay.
**
** DeMolay is a youth group for young men between the ages of 12 and 21.
** It teaches strong moral principles, as well as leadership skills and
** public speaking.  The donations page uses the 'pay for pixels' paradigm
** where, in this case, a pixel is only a single penny.  Donations can be
** made for as small as $4 or as high as a $100 block.  Each person who donates
** will get a link to their own site as well as acknowledgement on the
** donations blog located here http://www.amillionpixels.blogspot.com/
**
** If you wish to contact me you can use the following methods:
**
** Skype ID: jratcliff63367
** Yahoo: jratcliff63367
** AOL: jratcliff1961
** email: jratcliffscarab@gmail.com
**
**
** The MIT license:
**
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is furnished
** to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in all
** copies or substantial portions of the Software.

** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
** WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
** CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#include "Triangulator.h"


namespace TRIANGULATOR
{

typedef unsigned int TU32;

class TVec
{
public:
	TVec(double _x,double _y,double _z) { x = _x; y = _y; z = _z; };
	TVec(void) { };

  double x;
  double y;
  double z;
};

typedef std::vector< TVec >  TVecVector;
typedef std::vector< TU32 >  TU32Vector;

class CTriangulator : public Triangulator
{
public:
    ///     Default constructor
    CTriangulator();

    ///     Default destructor
    ~CTriangulator();

    ///     Triangulates the contour
    void triangulate(TU32Vector &indices);

    ///     Returns the given point in the triangulator array
    inline TVec get(const TU32 id) { return mPoints[id]; }

    virtual void reset(void)
    {
        mInputPoints.clear();
        mPoints.clear();
        mIndices.clear();
    }

    virtual void addPoint(float x,float y,float z)
    {
        addPoint( (double)x,(double)y,(double)z);
    }

    virtual void addPoint(double x,double y,double z)
    {
        TVec v(x,y,z);
        // update bounding box...
        if ( mInputPoints.empty() )
        {
            mMin = v;
            mMax = v;
        }
        else
        {
            if ( x < mMin.x ) mMin.x = x;
            if ( y < mMin.y ) mMin.y = y;
            if ( z < mMin.z ) mMin.z = z;

            if ( x > mMax.x ) mMax.x = x;
            if ( y > mMax.y ) mMax.y = y;
            if ( z > mMax.z ) mMax.z = z;
        }
        mInputPoints.push_back(v);
    }

    // Triangulation happens in 2d.  We could inverse transform the polygon around the normal direction, or we just use the two most signficant axes
    // Here we find the two longest axes and use them to triangulate.  Inverse transforming them would introduce more doubleing point error and isn't worth it.
    virtual unsigned int * triangulate(unsigned int &tcount,double epsilon)
    {
        unsigned int *ret = 0;
        tcount = 0;
        mEpsilon = epsilon;

        if ( !mInputPoints.empty() )
        {
            mPoints.clear();

          double dx = mMax.x - mMin.x; // locate the first, second and third longest edges and store them in i1, i2, i3
          double dy = mMax.y - mMin.y;
          double dz = mMax.z - mMin.z;

          unsigned int i1,i2,i3;

          if ( dx > dy && dx > dz )
          {
              i1 = 0;
              if ( dy > dz )
              {
                  i2 = 1;
                  i3 = 2;
              }
              else
              {
                  i2 = 2;
                  i3 = 1;
              }
          }
          else if ( dy > dx && dy > dz )
          {
              i1 = 1;
              if ( dx > dz )
              {
                  i2 = 0;
                  i3 = 2;
              }
              else
              {
                  i2 = 2;
                  i3 = 0;
              }
          }
          else
          {
              i1 = 2;
              if ( dx > dy )
              {
                  i2 = 0;
                  i3 = 1;
              }
              else
              {
                  i2 = 1;
                  i3 = 0;
              }
          }

          unsigned int pcount = mInputPoints.size();
          const double *points = &mInputPoints[0].x;
          for (unsigned int i=0; i<pcount; i++)
          {
            TVec v( points[i1], points[i2], points[i3] );
            mPoints.push_back(v);
            points+=3;
          }

          mIndices.clear();
          triangulate(mIndices);
          tcount = mIndices.size()/3;
          if ( tcount )
          {
              ret = &mIndices[0];
          }
        }
        return ret;
    }

    virtual void getPoint(unsigned int index,double &x,double &y,double &z) const
    {
        const TVec &t = mInputPoints[index];
        x = t.x;
        y = t.y;
        z = t.z;
    }

    virtual void getPoint(unsigned int index,float &x,float &y,float &z) const
    {
        const TVec &t = mInputPoints[index];
        x = (float)t.x;
        y = (float)t.y;
        z = (float)t.z;
    }


private:
    double                  mEpsilon;
    TVec                   mMin;
    TVec                   mMax;
    TVecVector             mInputPoints;
    TVecVector             mPoints;
    TU32Vector             mIndices;

    ///     Tests if a point is inside the given triangle
    bool _insideTriangle(const TVec& A, const TVec& B, const TVec& C,const TVec& P);

    ///     Returns the area of the contour
    double _area();

    bool _snip(int u, int v, int w, int n, int *V);

    ///     Processes the triangulation
    void _process(TU32Vector &indices);

};

///     Default constructor
CTriangulator::CTriangulator(void)
{
}

///     Default destructor
CTriangulator::~CTriangulator()
{
}

///     Triangulates the contour
void CTriangulator::triangulate(TU32Vector &indices)
{
    _process(indices);
}

///     Processes the triangulation
void CTriangulator::_process(TU32Vector &indices)
{
    const int n = mPoints.size();
    if (n < 3)
        return;
    int *V = new int[n];
	bool flipped = false;
    if (0.0f < _area())
    {
        for (int v = 0; v < n; v++)
            V[v] = v;
    }
    else
    {
        for (int v = 0; v < n; v++)
            V[v] = (n - 1) - v;
		flipped = true;
    }
    int nv = n;
    int count = 2 * nv;
    for (int m = 0, v = nv - 1; nv > 2;)
    {
        if (0 >= (count--))
            return;

        int u = v;
        if (nv <= u)
            u = 0;
        v = u + 1;
        if (nv <= v)
            v = 0;
        int w = v + 1;
        if (nv <= w)
            w = 0;

        if (_snip(u, v, w, nv, V))
        {
            int a, b, c, s, t;
            a = V[u];
            b = V[v];
            c = V[w];
			if ( flipped )
			{
				indices.push_back(a);
				indices.push_back(b);
				indices.push_back(c);
			}
			else
			{
				indices.push_back(c);
				indices.push_back(b);
				indices.push_back(a);
			}
            m++;
            for (s = v, t = v + 1; t < nv; s++, t++)
                V[s] = V[t];
            nv--;
            count = 2 * nv;
        }
    }

    delete []V;
}

///     Returns the area of the contour
double CTriangulator::_area()
{
    int n = mPoints.size();
    double A = 0.0f;
    for (int p = n - 1, q = 0; q < n; p = q++)
    {
        const TVec &pval = mPoints[p];
        const TVec &qval = mPoints[q];
        A += pval.x * qval.y - qval.x * pval.y;
    }
    return(A * 0.5f);
}

bool CTriangulator::_snip(int u, int v, int w, int n, int *V)
{
    int p;

    const TVec &A = mPoints[ V[u] ];
    const TVec &B = mPoints[ V[v] ];
    const TVec &C = mPoints[ V[w] ];

    if (mEpsilon > (((B.x - A.x) * (C.y - A.y)) - ((B.y - A.y) * (C.x - A.x))) )
        return false;

    for (p = 0; p < n; p++)
    {
        if ((p == u) || (p == v) || (p == w))
            continue;
        const TVec &P = mPoints[ V[p] ];
        if (_insideTriangle(A, B, C, P))
            return false;
    }
    return true;
}

///     Tests if a point is inside the given triangle
bool CTriangulator::_insideTriangle(const TVec& A, const TVec& B, const TVec& C,const TVec& P)
{
    double ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
    double cCROSSap, bCROSScp, aCROSSbp;

    ax = C.x - B.x;  ay = C.y - B.y;
    bx = A.x - C.x;  by = A.y - C.y;
    cx = B.x - A.x;  cy = B.y - A.y;
    apx = P.x - A.x;  apy = P.y - A.y;
    bpx = P.x - B.x;  bpy = P.y - B.y;
    cpx = P.x - C.x;  cpy = P.y - C.y;

    aCROSSbp = ax * bpy - ay * bpx;
    cCROSSap = cx * apy - cy * apx;
    bCROSScp = bx * cpy - by * cpx;

    return ((aCROSSbp >= 0.0f) && (bCROSScp >= 0.0f) && (cCROSSap >= 0.0f));
}

}; // end of namespace

using namespace TRIANGULATOR;

Triangulator * createTriangulator(void)
{
    CTriangulator *ct = new CTriangulator;
    return static_cast< Triangulator *>(ct);
}

void           releaseTriangulator(Triangulator *t)
{
    CTriangulator *ct = static_cast< CTriangulator *>(t);
    delete ct;
}

