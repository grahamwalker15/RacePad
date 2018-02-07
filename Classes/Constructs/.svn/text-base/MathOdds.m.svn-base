//
//  MathOdds.m
//  RacePad
//
//  Created by Gareth Griffith on 1/4/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "MathOdds.h"

@implementation MathOdds

+ (float) Average:(float *) values Count:(int)count
{
	if(count <= 0)
		return 0.0;
	
	double total = 0.0;
	
	for(int i = 0 ; i < count; i++)
		total += values[i];
	
	return total / (float)count;
}

+ (float) StandardDeviation:(float *) values Count:(int)count
{
	if(count <= 0)
		return 0.0;
	
	float average = [MathOdds Average:values Count:count];
	
	float std_dev_sq = 0.0;
	
	for(int i = 0 ; i < count ; i++)
		std_dev_sq += (values[i] - average) * (values[i] - average);
	
	return sqrt(std_dev_sq / (float)count );
}


// Normalisation routines

+ (float) FromNormalizeValue:(float)x OnScale:(float)x1 To:(float)x2;
{
	return x1 + x * ( x2 - x1) ;
}

+ (float) NormalizeValue:(float)x OnScale:(float)x1 To:(float)x2;
{
	if (x2 > x1)
		return (x - x1) / (x2 - x1)  ;
	else
		return 0.0  ;
	
}

// Geometry routines

+ (float) CalcGradientWithDX:(float)dx DY:(float)dy;
{
	double degrees = RadiansToDegrees ( atan2 ( dy , dx ) );
	
	return degrees ;
}

/*
double MathOdds::DistPointToLine(double x, double y, double x1, double y1, double x2, double y2)
{
	double l;
	double tx = x - x1;
	double ty = y - y1;
	double dx = x2 - x1;
	double dy = y2 - y1;
	l=(tx*dx+ty*dy)/(dx*dx+dy*dy);   // calc value of l minimizing |P0+l(P1-P0)-P|
	l=(l<0) ? 0 : ((l>1)? 1 : l);  // clip l to lie in [0,1]
	dx = tx - l*dx;dy = ty-l*dy;
	return sqrt(dx * dx + dy * dy);     // return distance of point from line
	
}

double MathOdds::NearestPointOnLine(double x, double y, double x1, double y1, double x2, double y2, double &nearest_x, double &nearest_y, double &alpha)
{
	double l;
	double tx = x - x1;
	double ty = y - y1;
	double dx = x2 - x1;
	double dy = y2 - y1;
	
	double denom = (dx*dx+dy*dy);
	if(denom > 0.0)  // Won't be if the two end points are identical and therefore the "line" is just a point
	{
		l=(tx*dx+ty*dy)/denom;   // calc value of l minimizing |P0+l(P1-P0)-P|
		l=(l<0) ? 0 : ((l>1)? 1 : l);  // clip l to lie in [0,1]
		dx = tx - l*dx;dy = ty-l*dy;
		
		// Set return variables
		nearest_x = x1 + l * dx ;
		nearest_y = y1 + l * dy ; 
		alpha = l ;
		return sqrt(dx * dx + dy * dy);     // return distance of point from line
	}
	else
	{
		alpha = 0.0;
		nearest_x = x1;
		nearest_y = y1;
		return sqrt(tx * tx + ty * ty);     // return distance of point the single point on line
	}
}

double MathOdds::NearestPointOnLine2(double x, double y, double x1, double y1, double x2, double y2, double &nearest_x, double &nearest_y, double &alpha)
{
	double l;
	double tx = x - x1;
	double ty = y - y1;
	double dx = x2 - x1;
	double dy = y2 - y1;
	
	double denom = (dx*dx+dy*dy);
	if(denom > 0.0)  // Won't be if the two end points are identical and therefore the "line" is just a point
	{
		l=(tx*dx+ty*dy)/denom;   // calc value of l minimizing |P0+l(P1-P0)-P|
		l=(l<0) ? 0 : ((l>1)? 1 : l);  // clip l to lie in [0,1]
		dx = tx - l*dx;dy = ty-l*dy;
		
		// Set return variables
		nearest_x = x1 + l * dx ;
		nearest_y = y1 + l * dy ; 
		alpha = l ;
		return dx * dx + dy * dy;     // return square of distance of point from line
	}
	else
	{
		alpha = 0.0;
		nearest_x = x1;
		nearest_y = y1;
		return tx * tx + ty * ty;     // return square of distance of point the single point on line
	}
}

double MathOdds::DistPointToPoint(double x1, double y1, double x2, double y2)
{
	double dx = (x2 - x1), dy = (y2 - y1) ;
	return sqrt( dx * dx + dy * dy ) ;
}


bool MathOdds::IntersectLines(double x1, double y1, double dx1, double dy1,
							  double x2, double y2, double dx2, double dy2,
							  double &x_int, double &y_int,
							  double &mu1, double &mu2, bool &true_intersection)
{
	
	double denom = (dx2*dy1 - dy2*dx1);
	
	// If denom = 0, the lines are parallel or degenerate - return false
	if(abs(denom) == 0.0)
	{
		return false;
	}
	else
	{
		
		if(dx1 != 0)
		{
			mu2 = (dx1*y2 - dx1*y1 + dy1*x1 - dy1*x2) / denom;
			mu1 = (x2 - x1 + mu2*dx2) / dx1;
		}
		else
		{
			mu2 = (dy1*x2 - dy1*x1 + dx1*y1 - dx1*y2) / denom;
			mu1 = (y2 - y1 + mu2*dy2) / dy1;
		}
		
		x_int = x1 + mu1 * dx1;
		y_int = y1 + mu1 * dy1;
		
		true_intersection = (mu1 >= 0.0 && mu1 <= 1.0 && mu2 >= 0.0 && mu2 <= 1.0);
		return true;
	}
}



float GoodRandom::GaussianValue()
{
	return ((Value() & 32767) + (Value() & 32767) + (Value() & 32767) +
			(Value() & 32767) + (Value() & 32767) + (Value() & 32767)) / (3*32767.0f) - 1.0f;
}
*/

@end
