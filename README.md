# SGuard

A secure, QR-based campus entry and exit management system designed to replace manual hostel and college gate registers.

SGuard enables institutions to digitally manage student movement, leave approvals, and gate access with real-time tracking, role-based permissions, and centralized records.

---

## Overview

SGuard modernizes traditional campus gate management by replacing manual logs with a secure digital workflow.

The platform provides:

* QR-based gate access
* Leave approval management
* Real-time entry and exit tracking
* Role-based access control
* Centralized record management

Designed to scale from individual hostels to institution-wide deployments.

---

## Core Features

### Student

* Generate Short Leave QR
* Request Long Leave approval
* Track leave status
* View personal records

### Warden / Staff

* Approve or reject leave requests
* Monitor student movement
* Access hostel-level records

### Admin

* Manage wardens and scanner devices
* Monitor institution-wide activity
* Access centralized records and approvals

---

## Leave System

SGuard supports two leave types:

### Short Leave (SL)

* Instant QR generation
* No approval required
* Time-restricted access

### Leave (L)

* Warden approval required
* QR issued after approval
* Extended duration access

QR validation and leave enforcement are managed exclusively by the backend.

---

## Technology Stack

| Layer           | Technology              |
| --------------- | ----------------------- |
| Mobile App      | Flutter                 |
| Backend         | Node.js + NestJS        |
| Database        | PostgreSQL              |
| Cache           | Redis                   |
| Authentication  | Firebase Authentication |
| Admin Dashboard | React                   |
| Infrastructure  | Cloud-based deployment  |

---

## Architecture

SGuard follows a **backend-first architecture**.

The frontend is responsible for user experience, while all business rules, validation, permissions, and QR verification are enforced by the backend.

### Key Principles

* Backend as the source of truth
* Secure QR validation
* Role-based authorization
* Scalable modular architecture
* Auditable system workflows

---

## Getting Started

### Backend

```bash
cd backend
npm install
npm run start:dev
```

### Mobile App

```bash
cd apps/mobile
flutter pub get
flutter run
```

### Admin Dashboard

```bash
cd apps/admin-web
npm install
npm run dev
```

## Vision

SGuard aims to make campus security and movement management smarter, faster, and fully digital.

---
