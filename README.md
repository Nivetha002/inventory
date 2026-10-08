# Inventory & POS Management System

A Flutter-based Inventory and Point of Sale (POS) management application designed for small businesses. The application helps manage products, categories, inventory, customers, billing, sales, users, and customer dues from a single platform.

It supports both **walk-in customers** and **registered customers**, including customer-linked sales and credit tracking.

## Features

### Authentication and User Management

- Supabase Authentication-based login.
- Role-based access with Admin, Manager, and Cashier roles.
- Create, activate, and deactivate user accounts.
- Store user profile details separately in the `profiles` table.
- Support for account status management.

### Product and Category Management

- Create, edit, and manage product categories.
- Create and edit products.
- Store product SKU and barcode details.
- Manage purchase price and selling price.
- Configure minimum stock levels.
- Activate or deactivate products.
- Search products by name, SKU, or barcode.

### Inventory Management

- Stock-in operation.
- Stock-out operation.
- Stock adjustment.
- Automatic stock deduction after a successful sale.
- Stock validation before completing a sale.
- Low-stock identification based on minimum stock level.
- Stock movement history.

### Customer Management

- Create and edit regular customers.
- Activate or deactivate customers.
- Support for walk-in customers.
- Link sales to registered customers.
- Track customer purchase totals.
- Track customer outstanding balances.
- Support credit sales for registered customers.

### POS Billing

- Search products by name, SKU, or barcode.
- Add products to the cart.
- Increase or decrease cart quantities.
- Remove products from the cart.
- Calculate subtotal, discount, tax, and total.
- Support Cash, UPI, Card, and Credit payment methods.
- Validate paid and due amounts.
- Require a registered customer for credit sales.
- Save completed sales and sale items.
- Automatically update product stock after billing.

### Sales Management

- View sales history.
- Store invoice number and sale details.
- View sold products and quantities.
- Track subtotal, discount, tax, total, paid amount, and due amount.
- Track payment method.
- Link sales to users and registered customers.
- Update customer outstanding balance for credit sales.

### Application States and Error Handling

- Loading states.
- Empty data states.
- Error states.
- Form validation.
- Invalid payment amount handling.
- Insufficient stock validation.
- Inactive product validation.
- Inactive customer validation.
- Credit sale without customer validation.

## Screens

The application includes the following screens:

- Login screen.
- Dashboard screen.
- User management screen.
- Category management screen.
- Product management screen.
- Stock management screen.
- Customer management screen.
- POS billing screen.
- Sales history screen.

## POS Billing Workflow

```text
Search Product
      ↓
Add Product to Cart
      ↓
Update Quantity
      ↓
Calculate Subtotal
      ↓
Apply Discount and Tax
      ↓
Select Customer
      ↓
Select Payment Method
      ↓
Enter Paid Amount
      ↓
Validate Payment
      ↓
Complete Sale
      ↓
Validate Stock
      ↓
Reduce Product Stock
      ↓
Create Stock Movement
      ↓
Save Sale and Sale Items
      ↓
Update Customer Balance
```

## Customer Types

### Walk-in Customer

A walk-in customer is used for one-time purchases when customer details do not need to be stored.

```text
Customer → Walk-in Customer
Payment  → Cash / UPI / Card
Sale     → Completed
```

The sale is stored without linking it to a registered customer.

### Registered Customer

A registered customer is selected from the Customer Management module.

```text
Customer → Registered Customer
Payment  → Cash / UPI / Card / Credit
Sale     → Completed
```

The sale is linked to the selected customer.

For credit sales:

```text
Registered Customer
        ↓
      Sale
        ↓
Outstanding Balance
```

## Payment Methods

| Payment Method | Customer Required | Due Supported |
|---|---:|---:|
| Cash | No | No |
| UPI | No | No |
| Card | No | No |
| Credit | Yes | Yes |

A credit sale can only be completed for a registered customer.

## Technology Stack

| Area | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State Management | Provider |
| Backend | Supabase |
| Authentication | Supabase Authentication |
| Database | PostgreSQL |
| Database Access | Supabase Flutter SDK |
| Architecture | Layered, repository-based architecture |
| UI | Flutter Material 3 |
| Version Control | Git |

## Architecture

The project follows a layered architecture that separates the user interface, state management, business logic, and database operations.

```text
UI / Screens
      ↓
Provider
      ↓
Business Logic
      ↓
Repository
      ↓
Supabase
      ↓
PostgreSQL
```

### UI Layer

Responsible for:

- Displaying screens.
- Handling user interactions.
- Managing forms.
- Showing loading, error, and empty states.
- Displaying data to the user.

### Provider Layer

Responsible for:

- Managing application state.
- Communicating between the UI and repositories.
- Notifying the UI when data changes.
- Handling loading and error states.

### Repository Layer

Responsible for:

- Database operations.
- CRUD operations.
- Product and customer management.
- Sales processing.
- Stock-related operations.
- Communication with Supabase.

### Supabase and PostgreSQL

Responsible for storing:

- Authentication data.
- User profiles.
- Roles and account status.
- Categories.
- Products.
- Stock movements.
- Customers.
- Sales.
- Sale items.

## Project Structure

```text
lib/
├── models/
│   ├── user_model.dart
│   ├── category_model.dart
│   ├── product_model.dart
│   ├── customer_model.dart
│   ├── cart_item_model.dart
│   └── sale_model.dart
│
├── providers/
│   ├── user_provider.dart
│   ├── category_provider.dart
│   ├── product_provider.dart
│   ├── customer_provider.dart
│   └── billing_provider.dart
│
├── repositories/
│   ├── user_repository.dart
│   ├── category_repository.dart
│   ├── product_repository.dart
│   ├── customer_repository.dart
│   └── sales_repository.dart
│
├── screens/
│   ├── auth/
│   ├── dashboard/
│   ├── users/
│   ├── categories/
│   ├── products/
│   ├── customers/
│   ├── billing/
│   └── sales/
│
├── core/
│   └── theme/
│
└── main.dart
```

## Database Design

The application uses PostgreSQL through Supabase.

### Main Tables

- `profiles`
- `categories`
- `products`
- `stock_movements`
- `customers`
- `sales`
- `sale_items`

### Main Relationships

```text
profiles
   │
   └── created_by
          ↓
        sales
          │
          └── sale_items
                 │
                 └── products
```

```text
customers
   │
   └── customer_id
          ↓
        sales
```

```text
categories
   │
   └── category_id
          ↓
        products
```

```text
products
   │
   └── product_id
          ↓
    stock_movements
```

## Sale Data

A completed sale contains:

- Invoice number.
- Customer reference, when applicable.
- Subtotal.
- Discount.
- Tax.
- Total amount.
- Payment method.
- Paid amount.
- Due amount.
- Created by user.
- Created date.
- Sale items.

Example:

```text
Sale
 ├── Product A × 2
 ├── Product B × 1
 └── Product C × 3
```

## Supabase Setup

### Prerequisites

- Flutter SDK.
- Android Studio or Visual Studio Code.
- Supabase account.
- Supabase project.
- Git.

### Add Supabase Package

```bash
flutter pub add supabase_flutter
```

### Initialize Supabase

Configure Supabase in `main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  publishableKey: 'YOUR_SUPABASE_PUBLISHABLE_KEY',
);
```

Do not add a Supabase service-role key or any secret key to the Flutter application.

Only the public Supabase URL and publishable key should be used in the client application.

## Authentication and Security

The application uses Supabase Authentication for user login.

The authentication flow is:

```text
Supabase Auth
      ↓
auth.users
      ↓
profiles
      ↓
Role and Account Status
```

Supported roles:

- `ADMIN`
- `MANAGER`
- `CASHIER`

Row Level Security (RLS) is enabled on the main application tables.

Administrative operations, such as creating users, should be handled through a secure backend function or server-side process. Privileged Supabase credentials must never be exposed inside the Flutter application.

## Run the Project

Install project dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Quality Checks

Format the project:

```bash
dart format lib
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Build Android APK

Create a release APK using:

```bash
flutter build apk --release
```

The generated APK is normally created at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Manual Testing Checklist

### Authentication and Users

- [ ] User can log in.
- [ ] Admin can create a user.
- [ ] User can be activated or deactivated.
- [ ] Role-based access works correctly.
- [ ] Inactive users cannot access the application.

### Categories and Products

- [ ] Category can be created.
- [ ] Category can be edited.
- [ ] Product can be created.
- [ ] Product can be edited.
- [ ] Product can be activated or deactivated.
- [ ] Product SKU can be saved.
- [ ] Product barcode can be saved.
- [ ] Minimum stock level can be configured.

### Stock

- [ ] Stock can be increased.
- [ ] Stock can be decreased.
- [ ] Stock adjustment works.
- [ ] Stock movement is created.
- [ ] Low-stock products are identified.
- [ ] Insufficient stock is rejected during billing.

### Customers

- [ ] Customer can be created.
- [ ] Customer can be edited.
- [ ] Customer can be activated or deactivated.
- [ ] Walk-in customer sale works.
- [ ] Registered customer can be selected during billing.
- [ ] Customer purchase total is updated.
- [ ] Customer due amount is updated for credit sales.

### Billing

- [ ] Products can be searched by name.
- [ ] Products can be searched by SKU.
- [ ] Products can be searched by barcode.
- [ ] Products can be added to the cart.
- [ ] Cart quantity can be increased.
- [ ] Cart quantity can be decreased.
- [ ] Products can be removed from the cart.
- [ ] Subtotal is calculated correctly.
- [ ] Discount is calculated correctly.
- [ ] Tax is calculated correctly.
- [ ] Cash payment works.
- [ ] UPI payment works.
- [ ] Card payment works.
- [ ] Credit payment works.
- [ ] Credit sales require a registered customer.
- [ ] Paid amount validation works.
- [ ] Due amount validation works.
- [ ] Inactive products cannot be sold.
- [ ] Inactive customers cannot be selected for credit sales.
- [ ] Stock is reduced after a successful sale.
- [ ] Sale items are saved correctly.

### Sales History

- [ ] Completed sale appears in Sales History.
- [ ] Invoice number is displayed.
- [ ] Customer details are displayed correctly.
- [ ] Payment method is displayed correctly.
- [ ] Paid amount is displayed correctly.
- [ ] Due amount is displayed correctly.
- [ ] Sale items are displayed correctly.

### Application Quality

- [ ] Loading states work.
- [ ] Empty states work.
- [ ] Error states work.
- [ ] Form validation works.
- [ ] `flutter analyze` passes.
- [ ] Tests pass successfully.
- [ ] Release APK builds successfully.

## Future Improvements

The following features are planned for future versions:

- Barcode and QR code scanning.
- Supplier management.
- Purchase management.
- Sales returns.
- Invoice and receipt generation.
- PDF and CSV reports.
- Sales and profit reports.
- Advanced dashboard analytics.
- SQLite offline support.
- Offline transaction synchronization.
- Supabase Realtime updates.
- Push notifications.
- Low-stock notifications.
- Customer payment history.
- Advanced search and filtering.
- Audit logs.
- Improved role-based permissions.
- PostgreSQL RPC functions for atomic sales transactions.
- Unit tests.
- Widget tests.
- Integration tests.

## Project Status

**Current Version:** MVP

The current version focuses on the core inventory and POS workflow:

```text
Authentication
      ↓
Users
      ↓
Categories
      ↓
Products
      ↓
Stock
      ↓
Customers
      ↓
Billing
      ↓
Sales
```

The MVP includes authentication, user management, product management, category management, stock management, customer management, POS billing, payment validation, credit sales, and sales history.

Additional enterprise-level features are planned for future releases.

## Author

**Nivetha**

Flutter Developer | Mobile Application Developer

- GitHub: [Nivetha002](https://github.com/Nivetha002)
- LinkedIn: [Nivetha](https://www.linkedin.com/in/nivetha002/)
