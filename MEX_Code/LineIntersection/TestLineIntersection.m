addpath('..\..\MEX\x64\');
load('W:\BugInLineIntersection','a2fReducedWaves','afLineSegment');

abIntersect = LineIntersection(a2fReducedWaves, afLineSegment);
abIntersect(8)
