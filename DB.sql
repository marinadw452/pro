CREATE DATABASE HandmadeStore
GO

USE HandmadeStore
GO

-- جدول المستخدمين
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20),
    UserType NVARCHAR(20) DEFAULT 'Customer' CHECK (UserType IN ('Customer', 'Seller', 'Admin')),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
)
GO

-- جدول عناوين المستخدمين
CREATE TABLE UserAddresses (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    AddressType NVARCHAR(20) DEFAULT 'Home' CHECK (AddressType IN ('Home', 'Work', 'Other')),
    Street NVARCHAR(255) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    State NVARCHAR(100),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100) NOT NULL,
    IsDefault BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
)
GO

-- جدول الفئات
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryDescription NTEXT,
    ParentCategoryID INT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
)
GO

-- جدول المنتجات
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    SellerID INT NOT NULL,
    CategoryID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    ProductDescription NTEXT,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    SKU NVARCHAR(50) UNIQUE,
    Weight DECIMAL(8, 3),
    Dimensions NVARCHAR(100),
    MaterialsUsed NTEXT,
    HandmadeTime NVARCHAR(100),
    IsCustomizable BIT DEFAULT 0,
    CustomizationOptions NTEXT,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
)
GO

-- جدول صور المنتجات
CREATE TABLE ProductImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageURL NVARCHAR(500) NOT NULL,
    ImageAlt NTEXT,
    IsPrimary BIT DEFAULT 0,
    DisplayOrder INT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
)
GO

-- جدول الطلبات
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    ShippingCost DECIMAL(8, 2) DEFAULT 0.00,
    TaxAmount DECIMAL(8, 2) DEFAULT 0.00,
    DiscountAmount DECIMAL(8, 2) DEFAULT 0.00,
    PaymentMethod NVARCHAR(20) NOT NULL CHECK (PaymentMethod IN ('CashOnDelivery', 'CreditCard', 'BankTransfer', 'DigitalWallet')),
    PaymentStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    ShippingAddress NTEXT NOT NULL,
    BillingAddress NTEXT,
    Notes NTEXT,
    EstimatedDeliveryDate DATE,
    ActualDeliveryDate DATE,
    TrackingNumber NVARCHAR(100),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Users(UserID)
)
GO

-- جدول تفاصيل الطلبات
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    SellerID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    CustomizationDetails NTEXT,
    ProductSnapshot NVARCHAR(MAX), -- JSON data
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
)
GO

-- جدول سلة التسوق
CREATE TABLE ShoppingCart (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    CustomizationDetails NTEXT,
    AddedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    UNIQUE (UserID, ProductID)
)
GO

-- جدول المراجعات والتقييمات
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    OrderID INT,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewTitle NVARCHAR(200),
    ReviewText NTEXT,
    IsVerifiedPurchase BIT DEFAULT 0,
    IsApproved BIT DEFAULT 1,
    HelpfulCount INT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
)
GO

-- جدول قوائم الرغبات
CREATE TABLE Wishlists (
    WishlistID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    UNIQUE (UserID, ProductID)
)
GO

-- جدول الإشعارات
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    NotificationType NVARCHAR(50) NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Message NTEXT NOT NULL,
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
)
GO

-- إنشاء الفهارس لتحسين الأداء
CREATE INDEX IX_Products_Seller ON Products(SellerID)
GO
CREATE INDEX IX_Products_Category ON Products(CategoryID)
GO
CREATE INDEX IX_Products_Active ON Products(IsActive)
GO
CREATE INDEX IX_Orders_Customer ON Orders(CustomerID)
GO
CREATE INDEX IX_Orders_Status ON Orders(OrderStatus)
GO
CREATE INDEX IX_Orders_Created ON Orders(CreatedAt)
GO
CREATE INDEX IX_Reviews_Product ON Reviews(ProductID)
GO
CREATE INDEX IX_Reviews_User ON Reviews(UserID)
GO
CREATE INDEX IX_Cart_User ON ShoppingCart(UserID)
GO

-- إدراج بيانات تجريبية للفئات
INSERT INTO Categories (CategoryName, CategoryDescription) VALUES
(N'الحرف اليدوية', N'منتجات مصنوعة يدوياً بمهارة حرفية عالية'),
(N'المجوهرات', N'مجوهرات وإكسسوارات مصنوعة يدوياً'),
(N'الديكور المنزلي', N'قطع زينة وديكور للمنزل'),
(N'الملابس والأقمشة', N'ملابس وأقمشة مطرزة ومصممة يدوياً'),
(N'الفخار والسيراميك', N'منتجات فخارية وخزفية'),
(N'الأعمال الخشبية', N'منتجات خشبية مصنوعة يدوياً'),
(N'اللوحات والرسم', N'لوحات فنية ورسومات'),
(N'المنسوجات', N'سجاد وبسط ومنسوجات يدوية')
GO

-- إدراج مستخدم إداري افتراضي
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, UserType) VALUES
(N'المدير', N'العام', 'admin@handmadestore.com', '$2y$10$encrypted_password_here', 'Admin')
GO
