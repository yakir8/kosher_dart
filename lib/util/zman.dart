///*
// * Zmanim Java API
// * Copyright (C) 2004-2011 Eliyahu Hershfeld
// *
// * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
// *  License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
// * any later version.
// *
// * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
// * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General  License for more
// * details.
// * You should have received a copy of the GNU Lesser General  License along with this library; if not, write to
// * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
// * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
// */
//package zmanim.util;
//
//import java.util.Comparator;
//import java.util.Date;
//
///*
// * Wrapper class for an astronomical time, mostly used to sort collections of
// * astronomical times.
// *
// * @author &copy; Eliyahu Hershfeld 2007-2011
// * @version 1.0
// */
// class Zman {
//  private String zmanLabel;
//  private Date zman;
//  private long duration;
//  private Date zmanDescription;
//
//   Zman(Date date, String label) {
//    this.zmanLabel = label;
//    this.zman = date;
//  }
//
//   Zman(long duration, String label) {
//    this.zmanLabel = label;
//    this.duration = duration;
//  }
//
//   Date getZman() {
//    return this.zman;
//  }
//
//   void setZman(Date date) {
//    this.zman = date;
//  }
//
//   long getDuration() {
//    return this.duration;
//  }
//
//   void setDuration(long duration) {
//    this.duration = duration;
//  }
//
//   String getZmanLabel() {
//    return this.zmanLabel;
//  }
//
//   void setZmanLabel(String label) {
//    this.zmanLabel = label;
//  }
//
//   static final Comparator<Zman> DATE_ORDER = new Comparator<Zman>() {
//   int compare(Zman z1, Zman z2) {
//    return z1.getZman().compareTo(z2.getZman());
//  }
//};
//
// static final Comparator<Zman> NAME_ORDER = new Comparator<Zman>() {
// int compare(Zman z1, Zman z2) {
//  return z1.getZmanLabel().compareTo(z2.getZmanLabel());
//}
//};
//
// static final Comparator<Zman> DURATION_ORDER = new Comparator<Zman>() {
// int compare(Zman z1, Zman z2) {
//  return z1.getDuration() == z2.getDuration() ? 0
//      : z1.getDuration() > z2.getDuration() ? 1 : -1;
//}
//};
//
///*
// * @return the zmanDescription
// */
// Date getZmanDescription() {
//  return this.zmanDescription;
//}
//
///*
// * @param zmanDescription
// *            the zmanDescription to set
// */
// void setZmanDescription(Date zmanDescription) {
//  this.zmanDescription = zmanDescription;
//}
//}
