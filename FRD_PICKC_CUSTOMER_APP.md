# Functional Requirements Document (FRD)
## Pick-C Customer Mobile Application

**Version**: 1.0  
**Date**: January 20, 2025  
**Project**: Pick-C Customer App  
**Platform**: Android & iOS (Flutter)

---

## Table of Contents

1. [Document Control](#document-control)
2. [Executive Summary](#executive-summary)
3. [Project Overview](#project-overview)
4. [Functional Requirements](#functional-requirements)
5. [User Stories](#user-stories)
6. [Features Description](#features-description)
7. [Technical Requirements](#technical-requirements)
8. [API Integration](#api-integration)
9. [User Interface Requirements](#user-interface-requirements)
10. [Non-Functional Requirements](#non-functional-requirements)
11. [Testing Requirements](#testing-requirements)
12. [Deployment Requirements](#deployment-requirements)

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-20 | Development Team | Initial Release |

**Approval Status**: ✅ Approved for Development

**Stakeholders**:
- Project Manager
- Product Owner
- Development Team
- QA Team
- Backend Team

---

## Executive Summary

### Purpose
This Functional Requirements Document (FRD) outlines the complete functionality of the Pick-C Customer mobile application, a comprehensive truck booking and logistics management system.

### Scope
The application enables customers to:
- Book trucks for cargo transportation
- Track drivers in real-time
- Make payments online and offline
- Manage booking history
- Rate drivers and services
- Access support and help

### Key Features
- ✅ User Authentication & Registration
- ✅ Truck Search & Booking
- ✅ Real-time Driver Tracking
- ✅ Payment Gateway Integration
- ✅ Booking History Management
- ✅ Invoice Management
- ✅ Rating & Review System

---

## Project Overview

### Application Name
**Pick-C Customer App**

### Target Platforms
- Android (Minimum SDK: 21)
- iOS (Minimum: iOS 12.0)

### Technology Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter/Flutter Navigation
- **HTTP Client**: Dio
- **Payment Gateway**: Razorpay
- **Maps**: Google Maps SDK
- **Push Notifications**: Firebase Cloud Messaging

### Base URL
```
Production: http://api.pickcargo.in/api
```

---

## Functional Requirements

### FR-1: Authentication Module

#### FR-1.1: User Login
**Priority**: High  
**Description**: Customer can log in using mobile number and password

**Input**:
- Mobile Number (10 digits)
- Password (8-20 characters with special requirements)

**Process**:
1. User enters mobile and password
2. System validates credentials
3. System returns authentication token
4. System registers device for push notifications

**Output**:
- Success: Redirect to Home/Dashboard
- Failure: Display error message

**API**: `POST /master/customer/login`

#### FR-1.2: User Registration
**Priority**: High  
**Description**: New customers can create an account

**Input**:
- User Name
- Mobile Number (10 digits)
- Email Address
- Password & Confirm Password

**Process**:
1. System checks if mobile number exists
2. System creates new account
3. System sends OTP to mobile
4. User verifies OTP on Terms & Conditions page

**Output**:
- Success: Account created, redirect to login
- Failure: Display error message

**API**: 
- `GET /master/customer/check/{mobile}`
- `POST /master/customer/save`
- `GET /master/customer/verifyOtp/{mobile}/{otp}`

#### FR-1.3: Forgot Password
**Priority**: Medium  
**Description**: Customers can reset password via OTP

**Process**:
1. User enters mobile number
2. System sends OTP via SMS
3. User enters new password
4. System updates password

**API**:
- `GET /master/customer/forgotPassword/{mobile}`
- `POST /master/customer/forgotPassword`

---

### FR-2: Truck Selection & Booking Module

#### FR-2.1: Vehicle Type Selection
**Priority**: High  
**Description**: Customer selects Open or Closed truck type

**Options**:
- Open Truck (For goods that can be exposed)
- Closed Truck (For protected goods)

**API**: `GET /master/customer/vehicleTypeList`

#### FR-2.2: Truck Size Selection
**Priority**: High  
**Description**: Customer selects truck size based on cargo

**Options**:
- Mini (Capacity: Up to 1 ton)
- Small (Capacity: 1-2 tons)
- Medium (Capacity: 2-5 tons)
- Large (Capacity: 5+ tons)

**API**: `GET /master/customer/vehicleGroupList`

#### FR-2.3: Cargo Type Selection
**Priority**: High  
**Description**: Customer selects cargo type

**Options**: Household items, Electronics, Furniture, Industrial goods, etc.

**API**: `GET /master/customer/cargoTypeList`

#### FR-2.4: Search Nearby Trucks
**Priority**: High  
**Description**: Customer searches for available trucks

**Input**:
- Pickup Location (Lat/Lng)
- Drop Location (Lat/Lng)
- Current Location (Lat/Lng)
- Vehicle Type
- Vehicle Group ID

**Output**:
- List of available trucks with:
  - Driver name and rating
  - Vehicle number
  - Distance from pickup
  - Estimated arrival time

**API**: `POST /master/customer/user`

#### FR-2.5: View Rate Card
**Priority**: High  
**Description**: Customer views pricing for selected truck type

**Shows**:
- Base Fare
- Per Kilometer Rate
- Per Hour Rate
- Minimum Fare

**API**: `GET /master/rateCard/{closedOpenId}/{truckId}`

#### FR-2.6: Get Trip Estimate
**Priority**: High  
**Description**: Customer gets fare estimate before booking

**Input**:
- Pickup & Drop coordinates
- Vehicle group and type
- Cargo type

**Output**:
- Estimated Fare
- Distance (km)
- Duration (minutes)

**API**: `POST /master/customer/tripEstimate`

#### FR-2.7: Confirm Booking
**Priority**: Critical  
**Description**: Customer confirms and creates booking

**Input**:
- Pickup Location (Address + Coordinates)
- Drop Location (Address + Coordinates)
- Vehicle Group ID
- Open/Closed ID
- Cargo Type
- Cargo Weight
- Rate Card ID
- Estimated Fare

**Process**:
1. System validates booking details
2. System assigns nearest driver
3. System sends confirmation with booking number
4. Customer receives notification

**Output**:
- Booking confirmation
- Booking number
- Driver details
- Estimated arrival time

**API**: `POST /master/customer/bookingSave`

#### FR-2.8: Cancel Booking
**Priority**: Medium  
**Description**: Customer can cancel booking before trip starts

**Input**:
- Booking Number
- Cancellation Reason

**Output**:
- Cancellation confirmation
- Refund details (if applicable)

**API**: `POST /master/customer/cancelBooking`

---

### FR-3: Driver Tracking Module

#### FR-3.1: View Driver Details
**Priority**: High  
**Description**: Customer views assigned driver information

**Shows**:
- Driver Name
- Phone Number
- Vehicle Details
- Rating
- Total Trips
- Photo

**API**: `GET /master/customer/isConfirm/{bno}`

#### FR-3.2: Track Driver Location
**Priority**: Critical  
**Description**: Real-time driver location tracking

**Features**:
- Live location on map
- Distance from pickup
- ETA updates
- Speed monitoring

**Update Frequency**: Every 5-10 seconds

**API**: `GET /master/customer/drivergeOposition/{dId}`

#### FR-3.3: Monitor Driver Status
**Priority**: High  
**Description**: Continuous monitoring of driver status

**Status Indicators**:
- Driver Assigned
- Driver En Route
- Driver Reached Pickup
- Trip Started
- Trip Completed

**API**: `GET /master/customer/driverMonitorInCustomer/{drvierId}`

#### FR-3.4: Check Driver Arrival
**Priority**: High  
**Description**: Notification when driver reaches pickup

**Process**:
1. System monitors driver location
2. When driver is within pickup radius
3. Send push notification to customer
4. Update booking status

**API**: `GET /master/customer/isReachPickupWaiting`

#### FR-3.5: View Driver Rating
**Priority**: Medium  
**Description**: Customer views driver's average rating

**Shows**:
- Overall rating (1-5 stars)
- Total ratings count
- Rating distribution

**API**: `GET /master/customer/avgDriverRating/{mDriverId}`

---

### FR-4: Payment Module

#### FR-4.1: View Bill Details
**Priority**: High  
**Description**: Customer views complete bill breakdown

**Shows**:
- Base Fare
- Distance Fare
- Time Fare
- Extra Charges
- Discount (if any)
- Final Amount
- Payment Status

**API**: `GET /master/customer/billDetails/{bno}`

#### FR-4.2: Cash Payment
**Priority**: Critical  
**Description**: Customer pays driver directly in cash

**Process**:
1. Customer confirms amount
2. Driver receives payment
3. System marks payment as received
4. Generate receipt

**API**: `GET /master/customer/pay/{bookingNo}/{mDriverId}/{payType}`

**Payment Type**: 1100 (Cash)

#### FR-4.3: Online Payment
**Priority**: Critical  
**Description**: Customer pays via online gateway (Razorpay)

**Process**:
1. Customer selects online payment
2. System fetches RSA key
3. Opens Razorpay payment gateway
4. Customer completes payment
5. System confirms payment

**API**: `POST /master/customer/getRSAKey`

#### FR-4.4: Check Payment Status
**Priority**: Medium  
**Description**: Customer checks if payment is due

**Shows**:
- Payment status (Paid/Pending)
- Due amount (if pending)
- Payment method

**API**: `GET /master/customer/customerPaymentsIsPaidCheck`

---

### FR-5: Invoice Module

#### FR-5.1: View Invoice
**Priority**: High  
**Description**: Customer views trip invoice

**Contains**:
- Invoice Number
- Booking Details
- Pickup & Drop Address
- Vehicle Details
- Driver Information
- Bill Breakdown
- Payment Details
- Tax Information

**API**: `GET /master/customer/tripInvoice/{bookingNumber}`

#### FR-5.2: Download Invoice
**Priority**: Medium  
**Description**: Customer downloads invoice as PDF

**Format**: PDF with company letterhead

#### FR-5.3: Email Invoice
**Priority**: Medium  
**Description**: Send invoice to customer email

**Process**:
1. Customer enters email address
2. System sends invoice PDF to email
3. Confirmation notification sent

**API**: `GET /master/customer/sendInvoiceMail/{bno}/{email}/true`

---

### FR-6: Booking History Module

#### FR-6.1: View Booking History
**Priority**: High  
**Description**: Customer views all past bookings

**Shows**:
- Booking Number
- Booking Date
- Pickup & Drop Locations
- Truck Type
- Status (Completed/Cancelled)
- Fare
- Driver Details

**API**: `GET /master/customer/bookingHistoryListbyCustomerMobileNo/{mobile}`

#### FR-6.2: View Booking Details
**Priority**: High  
**Description**: Customer views detailed booking information

**Shows**:
- Complete booking timeline
- Driver information
- Vehicle information
- Route details
- Payment details
- Rating status

**API**: `GET /master/customer/booking/{bookingno}`

---

### FR-7: Rating Module

#### FR-7.1: Rate Driver
**Priority**: High  
**Description**: Customer rates driver after trip completion

**Input**:
- Driver ID
- Rating (1-5 stars)
- Comment (Optional)
- Booking Number

**Process**:
1. Customer completes trip
2. System prompts for rating
3. Customer submits rating
4. System updates driver rating

**Output**:
- Rating submitted successfully
- Thank you message

**API**: `POST /master/customer/driverRating`

---

### FR-8: Profile Module

#### FR-8.1: View Profile
**Priority**: Medium  
**Description**: Customer views personal profile

**Shows**:
- Name
- Mobile Number
- Email Address
- Address
- Account Status

**API**: `GET /master/customer/{mobile}`

#### FR-8.2: Update Profile
**Priority**: Medium  
**Description**: Customer updates profile information

**Input**:
- Name
- Email
- Address
- Password

**Process**:
1. Customer enters new details
2. System validates password
3. System updates profile
4. Confirmation sent

**API**: `POST /master/customer/{mobile}`

#### FR-8.3: Change Password
**Priority**: Medium  
**Description**: Customer changes password

**Input**:
- Old Password
- New Password
- Confirm Password

**API**: `POST /master/customer/changePassword/{mobile}`

---

### FR-9: Support Module

#### FR-9.1: Send Query/Feedback
**Priority**: Low  
**Description**: Customer can send queries to support

**Input**:
- Customer Mobile
- Subject
- Message
- Query Type

**Process**:
1. Customer fills contact form
2. System sends query to support
3. Confirmation shown

**API**: `POST /master/customer/sendMessageToPickC`

---

## User Stories

### US-1: As a new customer, I want to register
**Given**: User opens app for first time  
**When**: User completes registration form  
**Then**: User receives OTP and creates account

### US-2: As a customer, I want to book a truck
**Given**: User is logged in  
**When**: User selects pickup/drop locations  
**Then**: System shows available trucks and user books

### US-3: As a customer, I want to track my driver
**Given**: Booking is confirmed  
**When**: User opens tracking screen  
**Then**: Real-time driver location displayed

### US-4: As a customer, I want to pay for my trip
**Given**: Trip is completed  
**When**: User views bill  
**Then**: User can pay via cash or online

### US-5: As a customer, I want to rate my driver
**Given**: Trip is completed  
**When**: User opens rating screen  
**Then**: User submits rating and feedback

---

## Features Description

### Core Features
1. ✅ User Registration & Login
2. ✅ Mobile OTP Verification
3. ✅ Truck Search & Selection
4. ✅ Real-time Driver Tracking
5. ✅ Online & Cash Payments
6. ✅ Invoice Generation
7. ✅ Booking History
8. ✅ Driver Rating System
9. ✅ Profile Management
10. ✅ Support & Feedback

### Supporting Features
1. ✅ GPS Location Services
2. ✅ Push Notifications
3. ✅ Offline Data Caching
4. ✅ Dark Mode Support
5. ✅ Multilingual Support
6. ✅ Social Media Login

---

## Technical Requirements

### Frontend Requirements

#### Technology Stack
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **Maps**: Google Maps SDK
- **Payment**: Razorpay SDK

#### API Integration
- **Total Endpoints**: 36+
- **Base URL**: http://api.pickcargo.in/api
- **Authentication**: Bearer Token
- **Content-Type**: application/json

#### UI/UX Requirements
- Material Design 3
- Responsive Layout
- Accessibility Support
- Splash Screen
- Onboarding Flow

### Backend Requirements

#### API Endpoints (36 Total)

**Authentication (8 endpoints)**:
1. POST `/master/customer/login`
2. POST `/master/customer/save`
3. GET `/master/customer/check/{mobile}`
4. GET `/master/customer/{mobile}`
5. POST `/master/customer/deviceId`
6. GET `/master/customer/verifyOtp/{mobile}/{otp}`
7. GET `/master/customer/forgotPassword/{mobile}`
8. POST `/master/customer/forgotPassword`

**Vehicle & Booking (7 endpoints)**:
1. GET `/master/customer/vehicleGroupList`
2. GET `/master/customer/vehicleTypeList`
3. GET `/master/customer/cargoTypeList`
4. POST `/master/customer/user`
5. GET `/master/rateCard/{closedOpenId}/{truckId}`
6. POST `/master/customer/tripEstimate`
7. POST `/master/customer/bookingSave`

**Driver Tracking (4 endpoints)**:
1. GET `/master/customer/isConfirm/{bno}`
2. GET `/master/customer/drivergeOposition/{dId}`
3. GET `/master/customer/avgDriverRating/{mDriverId}`
4. GET `/master/customer/isReachPickupWaiting`

**Payment (5 endpoints)**:
1. GET `/master/customer/billDetails/{bno}`
2. GET `/master/customer/pay/{bookingNo}/{mDriverId}/{payType}`
3. POST `/master/customer/getRSAKey`
4. GET `/master/customer/tripInvoice/{bookingNumber}`
5. GET `/master/customer/sendInvoiceMail/{bno}/{email}/true`

**Additional (12 endpoints)**:
- Profile management
- Booking history
- Rating submission
- Support queries

---

## User Interface Requirements

### Screen List

#### Authentication Screens
1. **Splash Screen**: App logo and loading
2. **Login Screen**: Mobile and password input
3. **Sign Up Screen**: Registration form
4. **OTP Verification**: OTP input
5. **Forgot Password**: Mobile input and reset

#### Home & Booking Screens
6. **Home Screen**: Quick actions and active trips
7. **Map Screen**: Google Maps with location selection
8. **Truck Selection**: Vehicle type and size selection
9. **Cargo Selection**: Cargo type input
10. **Booking Confirmation**: Booking summary and confirm

#### Active Trip Screens
11. **Driver Details**: Driver information
12. **Live Tracking**: Real-time driver location
13. **Booking Status**: Trip status updates

#### Payment & Invoice Screens
14. **Payment Screen**: Bill details and payment options
15. **Cash Payment**: Cash payment confirmation
16. **Online Payment**: Razorpay gateway
17. **Invoice Screen**: Trip invoice display

#### Profile & Settings Screens
18. **Profile Screen**: User profile view
19. **Edit Profile**: Update profile details
20. **Change Password**: Password change form
21. **Settings**: App settings

#### Other Screens
22. **Booking History**: Past bookings list
23. **Booking Details**: Detailed booking view
24. **Rating Screen**: Driver rating form
25. **Help/Support**: Contact support

---

## Non-Functional Requirements

### Performance Requirements
- **App Launch Time**: < 3 seconds
- **API Response Time**: < 2 seconds
- **Screen Transitions**: Smooth, no lag
- **Map Rendering**: < 5 seconds
- **Image Loading**: < 1 second per image

### Scalability
- Support for 10,000+ concurrent users
- Handle 1000+ bookings per day
- Real-time tracking for 500+ active trips

### Security
- Secure API authentication (Bearer tokens)
- Encrypted local storage
- Secure payment gateway integration
- No sensitive data in logs
- HTTPS for all API calls

### Reliability
- 99% uptime requirement
- Automatic error recovery
- Network failure handling
- Offline data caching

### Usability
- Intuitive navigation
- Minimal learning curve
- Error messages in user language
- Help tooltips available

---

## Testing Requirements

### Unit Testing
- [ ] API service methods
- [ ] Data models serialization
- [ ] Utility functions
- [ ] Authentication flow

### Integration Testing
- [ ] End-to-end booking flow
- [ ] Payment integration
- [ ] Driver tracking
- [ ] Notification handling

### UI Testing
- [ ] All screen navigation
- [ ] Form validations
- [ ] Error handling
- [ ] Loading states

### Manual Testing Checklist
- See `RELEASE_BUILD_TESTING_GUIDE.md` for complete checklist

---

## Deployment Requirements

### Android
- **Target SDK**: 34
- **Min SDK**: 21
- **Build Tool**: Gradle 8.0+
- **Output**: APK & AAB

### iOS
- **Target iOS**: 12.0+
- **Build Tool**: Xcode 14.0+
- **Output**: IPA

### Release Checklist
- [ ] Version updated in pubspec.yaml
- [ ] ProGuard rules configured
- [ ] API keys secured
- [ ] Signing certificates ready
- [ ] Release notes prepared
- [ ] Testing completed
- [ ] Documentation updated

---

## Appendices

### A. API Reference
See `API_INTEGRATION_ANALYSIS.md` for complete API documentation

### B. Build Guide
See `BUILD_FIX_GUIDE.md` for build instructions

### C. Testing Guide
See `RELEASE_BUILD_TESTING_GUIDE.md` for test procedures

### D. Implementation Guide
See `API_IMPLEMENTATION_GUIDE.md` for code examples

---

## Document Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Manager | | | |
| Product Owner | | | |
| Development Lead | | | |
| QA Lead | | | |

---

**Document Version**: 1.0  
**Last Updated**: January 20, 2025  
**Status**: Final  
**Distribution**: Development Team, QA Team, Backend Team



