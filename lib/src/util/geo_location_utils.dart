/*
 * Zmanim Java API
 * Copyright (C) 2004-2018 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:kosher_dart/src/util/geo_location.dart';

/// A class for various location calculations
/// Most of the code in this class is ported from <a href="http://www.movable-type.co.uk/">Chris Veness'</a>
/// <a href="http://www.fsf.org/licensing/licenses/lgpl.html">LGPL</a> Javascript Implementation
///
/// @author &copy; Eliyahu Hershfeld 2009 - 2018
class GeoLocationUtils {
  /// Constant for a distance type calculation.
  /// @see #getGeodesicDistance(GeoLocation, GeoLocation)
  static const int _DISTANCE = 0;

  /// Constant for a initial bearing type calculation.
  /// @see #getGeodesicInitialBearing(GeoLocation, GeoLocation)
  static const int _INITIAL_BEARING = 1;

  /// Constant for a final bearing type calculation.
  /// @see #getGeodesicFinalBearing(GeoLocation, GeoLocation)
  static const int _FINAL_BEARING = 2;

  /// Calculate the <a href="http://en.wikipedia.org/wiki/Great_circle">geodesic</a> initial bearing between this Object and
  /// a second Object passed to this method using <a href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus
  /// Vincenty's</a> inverse formula See T Vincenty, "<a href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and
  /// Inverse Solutions of Geodesics on the Ellipsoid with application of nested equations</a>", Survey Review, vol XXII
  /// no 176, 1975.
  ///
  /// @param location
  ///            the initial location
  /// @param destination
  ///            the destination location
  /// @return the geodesic bearing
  static double getGeodesicInitialBearing(
      GeoLocation location, GeoLocation destination) {
    return _vincentyFormula(location, destination, _INITIAL_BEARING);
  }

  /// Calculate the <a href="http://en.wikipedia.org/wiki/Great_circle">geodesic</a> final bearing between this Object
  /// and a second Object passed to this method using <a href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a>
  /// inverse formula See T Vincenty, "<a href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics
  /// on the Ellipsoid with application of nested equations</a>", Survey Review, vol XXII no 176, 1975.
  ///
  /// @param location
  ///            the initial location
  /// @param destination
  ///            the destination location
  /// @return the geodesic bearing
  static double getGeodesicFinalBearing(
      GeoLocation location, GeoLocation destination) {
    return _vincentyFormula(location, destination, _FINAL_BEARING);
  }

  /// Calculate <a href="http://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</a> in Meters
  /// between this Object and a second Object passed to this method using <a
  /// href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty,
  /// "<a href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the
  /// Ellipsoid with application of nested equations</a>", Survey Review, vol XXII no 176, 1975. This uses the
  /// WGS-84 geodetic model.
  ///
  /// @param location
  ///            the initial location
  /// @param destination
  ///            the destination location
  /// @return the geodesic distance in Meters
  static double getGeodesicDistance(
      GeoLocation location, GeoLocation destination) {
    return _vincentyFormula(location, destination, _DISTANCE);
  }

  /// Calculates the initial <a href="http://en.wikipedia.org/wiki/Great_circle">geodesic</a> bearing, final bearing or
  /// <a href="http://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</a> using <a href=
  /// "http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
  /// href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
  /// with application of nested equations</a>", Survey Review, vol XXII no 176, 1975.
  ///
  /// @param location
  ///            the initial location
  /// @param destination
  ///            the destination location
  /// @param formula
  ///            This formula calculates initial bearing ({@link #INITIAL_BEARING}),
  ///            final bearing ({@link #FINAL_BEARING}) and distance ({@link #DISTANCE}).
  /// @return
  ///            the geodesic distance, initial or final bearing (based on the formula passed in) between the location
  ///            and destination in Meters
  /// @see #getGeodesicDistance(GeoLocation, GeoLocation)
  /// @see #getGeodesicInitialBearing(GeoLocation, GeoLocation)
  /// @see #getGeodesicFinalBearing(GeoLocation, GeoLocation)
  static double _vincentyFormula(
      GeoLocation location, GeoLocation destination, int formula) {
    double a =
        6378137; // length of semi-major axis of the ellipsoid (radius at equator) in metres based on WGS-84
    double b =
        6356752.3142; // length of semi-minor axis of the ellipsoid (radius at the poles) in meters based on WGS-84
    double f = 1 / 298.257223563; // flattening of the ellipsoid based on WGS-84
    double L = radians(destination.getLongitude() -
        location.getLongitude()); //difference in longitude of two points;
    double u1 = atan((1 - f) *
        tan(radians(location
            .getLatitude()))); // reduced latitude (latitude on the auxiliary sphere)
    double u2 = atan((1 - f) *
        tan(radians(destination
            .getLatitude()))); // reduced latitude (latitude on the auxiliary sphere)

    double sinU1 = sin(u1), cosU1 = cos(u1);
    double sinU2 = sin(u2), cosU2 = cos(u2);

    double lambda = L;
    double lambdaP = 2 * pi;
    double iterLimit = 20;
    double sinLambda = 0;
    double cosLambda = 0;
    double sinSigma = 0;
    double cosSigma = 0;
    double sigma = 0;
    double sinAlpha = 0;
    double cosSqAlpha = 0;
    double cos2SigmaM = 0;
    double C;
    while ((lambda - lambdaP).abs() > 1e-12 && --iterLimit > 0) {
      sinLambda = sin(lambda);
      cosLambda = cos(lambda);
      sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
          (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
      if (sinSigma == 0) return 0; // co-incident points
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
      if (cos2SigmaM.isNaN) {
        cos2SigmaM = 0;
      } // equatorial line: cosSqAlpha=0 (§6)
      C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L +
          (1 - C) *
              f *
              sinAlpha *
              (sigma +
                  C *
                      sinSigma *
                      (cos2SigmaM +
                          C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    }
    if (iterLimit == 0) return double.nan; // formula failed to converge

    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A =
        1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B *
        sinSigma *
        (cos2SigmaM +
            B /
                4 *
                (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
                    B /
                        6 *
                        cos2SigmaM *
                        (-3 + 4 * sinSigma * sinSigma) *
                        (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    double distance = b * A * (sigma - deltaSigma);

    // initial bearing
    double fwdAz = degrees(
        atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
    // final bearing
    double revAz = degrees(
        atan2(cosU1 * sinLambda, -sinU1 * cosU2 + cosU1 * sinU2 * cosLambda));
    if (formula == _DISTANCE) {
      return distance;
    } else if (formula == _INITIAL_BEARING) {
      return fwdAz;
    } else if (formula == _FINAL_BEARING) {
      return revAz;
    } else {
      // should never happen
      return double.nan;
    }
  }

  /// Returns the <a href="http://en.wikipedia.org/wiki/Rhumb_line">rhumb line</a>
  /// bearing from the current location to the GeoLocation passed in.
  ///
  /// @param location
  ///            the initial location
  /// @param destination
  ///            the destination location
  /// @return the bearing in degrees
  static double getRhumbLineBearing(
      GeoLocation location, GeoLocation destination) {
    double dLon = radians(destination.getLongitude() - location.getLongitude());
    double dPhi = log(tan(radians(destination.getLatitude()) / 2 + pi / 4) /
        tan(radians(location.getLatitude()) / 2 + pi / 4));
    if (dLon.abs() > pi) dLon = dLon > 0 ? -(2 * pi - dLon) : (2 * pi + dLon);
    return degrees(atan2(dLon, dPhi));
  }

  /// Returns the <a href="http://en.wikipedia.org/wiki/Rhumb_line">rhumb line</a> distance between two GeoLocations
  /// passed in. Ported from <a href="http://www.movable-type.co.uk/">Chris Veness'</a> Javascript Implementation.
  ///
  /// @param location
  ///            the initial location
  /// @param destination
  ///            the destination location
  /// @return the distance in Meters
  static double getRhumbLineDistance(
      GeoLocation location, GeoLocation destination) {
    double earthRadius = 6378137; // Earth's radius in meters (WGS-84)
    double dLat =
        radians(location.getLatitude()) - radians(destination.getLatitude());
    double dLon =
        (radians(location.getLongitude()) - radians(destination.getLongitude()))
            .abs();
    double dPhi = log(tan(radians(location.getLatitude()) / 2 + pi / 4) /
        tan(radians(destination.getLatitude()) / 2 + pi / 4));
    double q = dLat / dPhi;

    if (!q.isFinite) {
      q = cos(radians(destination.getLatitude()));
    }
    // if dLon over 180° take shorter rhumb across 180° meridian:
    if (dLon > pi) {
      dLon = 2 * pi - dLon;
    }
    double d = sqrt(dLat * dLat + q * q * dLon * dLon);
    return d * earthRadius;
  }
}
