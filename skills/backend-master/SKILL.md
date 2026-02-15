---
name: backend-master
description: >
  Comprehensive backend development guide covering Node.js, Python, .NET
  patterns, API architecture, frontend handoff, and production best
  practices. Consolidates 7 backend skills.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
context: fork
---

# ©2026 Brad Scheller

# Backend Master

Comprehensive backend development guide consolidating Node.js, Python, .NET patterns, API design, authentication, security, and production deployment. This skill combines patterns from 7 specialized backend skills into a single authoritative reference.

## When to Use

- Designing RESTful, GraphQL, or gRPC APIs
- Building authentication/authorization systems
- Implementing layered architecture (controller/service/repository)
- Creating production-ready Node.js, Python, or .NET backends
- Optimizing database queries and transactions
- Frontend-backend handoff documentation
- Security hardening (OWASP Top 10)
- Performance optimization and caching
- Error handling and logging strategies

## 1. Architecture Patterns

### Layered Architecture (Controller → Service → Repository)

**Structure:**
```
src/
├── controllers/     # HTTP request/response handling
├── services/        # Business logic
├── repositories/    # Data access layer
├── models/          # Data models/entities
├── middleware/      # Express/Fastify middleware
├── routes/          # Route definitions
├── utils/           # Helper functions
├── config/          # Configuration
└── types/           # TypeScript types
```

**Controller Layer (Thin):**
```typescript
// controllers/user.controller.ts
import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/user.service';

export class UserController {
  constructor(private userService: UserService) {}

  async createUser(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await this.userService.createUser(req.body);
      res.status(201).json(user);
    } catch (error) {
      next(error);
    }
  }

  async getUser(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await this.userService.getUserById(req.params.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
  }
}
```

**Service Layer (Business Logic):**
```typescript
// services/user.service.ts
import { UserRepository } from '../repositories/user.repository';
import { NotFoundError, ValidationError } from '../utils/errors';
import bcrypt from 'bcrypt';

export class UserService {
  constructor(private userRepository: UserRepository) {}

  async createUser(userData: CreateUserDTO): Promise<User> {
    // Validation
    const existingUser = await this.userRepository.findByEmail(userData.email);
    if (existingUser) {
      throw new ValidationError('Email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(userData.password, 10);

    // Create user
    const user = await this.userRepository.create({
      ...userData,
      password: hashedPassword
    });

    // Remove password from response
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  async getUserById(id: string): Promise<User> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new NotFoundError('User not found');
    }
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }
}
```

**Repository Layer (Data Access):**
```typescript
// repositories/user.repository.ts
import { Pool } from 'pg';

export class UserRepository {
  constructor(private db: Pool) {}

  async create(userData: CreateUserDTO & { password: string }): Promise<UserEntity> {
    const query = `
      INSERT INTO users (name, email, password)
      VALUES ($1, $2, $3)
      RETURNING id, name, email, password, created_at, updated_at
    `;
    const { rows } = await this.db.query(query, [
      userData.name,
      userData.email,
      userData.password
    ]);
    return rows[0];
  }

  async findById(id: string): Promise<UserEntity | null> {
    const query = 'SELECT * FROM users WHERE id = $1';
    const { rows } = await this.db.query(query, [id]);
    return rows[0] || null;
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    const query = 'SELECT * FROM users WHERE email = $1';
    const { rows } = await this.db.query(query, [email]);
    return rows[0] || null;
  }
}
```

### Dependency Injection Pattern

```typescript
// di-container.ts
import { Pool } from 'pg';
import { UserRepository } from './repositories/user.repository';
import { UserService } from './services/user.service';
import { UserController } from './controllers/user.controller';

class Container {
  private instances = new Map<string, any>();

  singleton<T>(key: string, factory: () => T): void {
    let instance: T;
    this.instances.set(key, () => {
      if (!instance) {
        instance = factory();
      }
      return instance;
    });
  }

  resolve<T>(key: string): T {
    const factory = this.instances.get(key);
    if (!factory) {
      throw new Error(`No factory registered for ${key}`);
    }
    return factory();
  }
}

export const container = new Container();

// Register dependencies
container.singleton('db', () => new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
}));

container.singleton('userRepository', () =>
  new UserRepository(container.resolve('db'))
);

container.singleton('userService', () =>
  new UserService(container.resolve('userRepository'))
);

container.singleton('userController', () =>
  new UserController(container.resolve('userService'))
);
```

### Monolith vs Microservices Decision Matrix

| Factor | Monolith | Microservices |
|--------|----------|---------------|
| **Team Size** | < 10 developers | > 10 developers, multiple teams |
| **Domain Clarity** | Unclear boundaries | Clear bounded contexts |
| **Scaling Needs** | Uniform load | Independent service scaling |
| **Deployment** | All-or-nothing | Independent deployments |
| **Consistency** | ACID transactions | Eventual consistency |
| **Best For** | MVPs, startups, small apps | Large orgs, clear domains |

**When to Choose Monolith:**
- Small team (< 10 developers)
- Rapid prototyping/MVP
- Unclear domain boundaries
- Need strong consistency (ACID)

**When to Choose Microservices:**
- Large teams with clear ownership
- Need independent scaling
- Well-defined domain boundaries
- Polyglot technology requirements

## 2. Node.js Patterns

### Express.js Setup (Production-Ready)

```typescript
import express, { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import { errorHandler } from './middleware/error-handler';
import { requestLogger } from './middleware/logger';
import { apiLimiter } from './middleware/rate-limit';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true
}));
app.use(compression());

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
app.use(requestLogger);

// Rate limiting
app.use('/api/', apiLimiter);

// Routes
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/posts', postRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling (must be last)
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});
```

### Fastify Setup (High Performance)

```typescript
import Fastify from 'fastify';
import helmet from '@fastify/helmet';
import cors from '@fastify/cors';
import compress from '@fastify/compress';

const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    transport: {
      target: 'pino-pretty',
      options: { colorize: true }
    }
  }
});

// Plugins
await fastify.register(helmet);
await fastify.register(cors, { origin: true });
await fastify.register(compress);

// Type-safe routes with schema validation
fastify.post<{
  Body: { name: string; email: string };
  Reply: { id: string; name: string };
}>('/users', {
  schema: {
    body: {
      type: 'object',
      required: ['name', 'email'],
      properties: {
        name: { type: 'string', minLength: 1 },
        email: { type: 'string', format: 'email' }
      }
    }
  }
}, async (request, reply) => {
  const { name, email } = request.body;
  return { id: '123', name };
});

await fastify.listen({ port: 3000, host: '0.0.0.0' });
```

### Async Patterns and Error Handling

```typescript
// Async handler wrapper
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Usage
router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  res.json(user);
}));
```

## 3. Python Backend (FastAPI)

### FastAPI Setup

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from typing import List

app = FastAPI(title="User API", version="1.0.0")

# Pydantic models (request/response DTOs)
class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

    class Config:
        from_attributes = True

# Dependency injection
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/api/v1/users", response_model=UserResponse, status_code=201)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
):
    # Check existing user
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email already exists")

    # Hash password
    hashed_password = hash_password(user.password)

    # Create user
    db_user = User(
        name=user.name,
        email=user.email,
        password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return db_user

@app.get("/api/v1/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### SQLAlchemy Integration

```python
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# Database setup
DATABASE_URL = "postgresql://user:password@localhost/dbname"
engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# Model
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Create tables
Base.metadata.create_all(bind=engine)
```

## 4. .NET Patterns

### ASP.NET Core Minimal API

```csharp
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();

var app = builder.Build();

// Endpoints
app.MapGet("/api/v1/users/{id}", async (int id, IUserService userService) =>
{
    var user = await userService.GetUserByIdAsync(id);
    return user is not null ? Results.Ok(user) : Results.NotFound();
});

app.MapPost("/api/v1/users", async (CreateUserDto dto, IUserService userService) =>
{
    var user = await userService.CreateUserAsync(dto);
    return Results.Created($"/api/v1/users/{user.Id}", user);
});

app.Run();
```

### Dependency Injection (Traditional Controller)

```csharp
// Service interface
public interface IUserService
{
    Task<UserDto> GetUserByIdAsync(int id);
    Task<UserDto> CreateUserAsync(CreateUserDto dto);
}

// Service implementation
public class UserService : IUserService
{
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger;

    public UserService(IUserRepository repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<UserDto> GetUserByIdAsync(int id)
    {
        var user = await _repository.GetByIdAsync(id);
        if (user == null)
        {
            throw new NotFoundException("User not found");
        }
        return MapToDto(user);
    }
}

// Controller
[ApiController]
[Route("api/v1/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UserDto>> GetUser(int id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        return Ok(user);
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> CreateUser(CreateUserDto dto)
    {
        var user = await _userService.CreateUserAsync(dto);
        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }
}
```

### Entity Framework Core

```csharp
// DbContext
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
        });
    }
}

// Repository
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<User> GetByIdAsync(int id)
    {
        return await _context.Users.FindAsync(id);
    }

    public async Task<User> CreateAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}
```

## 5. Authentication & Authorization

### OAuth 2.1 with PKCE (2025 Standard)

```typescript
import crypto from 'crypto';

// Step 1: Generate code verifier and challenge
const codeVerifier = crypto.randomBytes(32).toString('base64url');
const codeChallenge = crypto
  .createHash('sha256')
  .update(codeVerifier)
  .digest('base64url');

// Step 2: Authorization URL
const authUrl = new URL('https://auth.example.com/authorize');
authUrl.searchParams.set('client_id', 'your-client-id');
authUrl.searchParams.set('redirect_uri', 'https://app.example.com/callback');
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('scope', 'openid profile email');
authUrl.searchParams.set('state', crypto.randomBytes(16).toString('hex'));
authUrl.searchParams.set('code_challenge', codeChallenge);
authUrl.searchParams.set('code_challenge_method', 'S256');

// Step 3: Exchange code for token
const tokenResponse = await fetch('https://auth.example.com/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    code: authCode,
    redirect_uri: redirectUri,
    client_id: clientId,
    code_verifier: codeVerifier,
  }),
});
```

### JWT Implementation (Best Practices)

```typescript
import jwt from 'jsonwebtoken';

// Generate JWT (RS256 - asymmetric signing)
const accessToken = jwt.sign(
  {
    sub: user.id,
    email: user.email,
    roles: user.roles,
  },
  process.env.JWT_PRIVATE_KEY,
  {
    algorithm: 'RS256',
    expiresIn: '15m',
    issuer: 'https://api.example.com',
    audience: 'https://app.example.com',
  }
);

// Verify JWT
const decoded = jwt.verify(token, process.env.JWT_PUBLIC_KEY, {
  algorithms: ['RS256'],
  issuer: 'https://api.example.com',
  audience: 'https://app.example.com',
});
```

**JWT Best Practices (2025):**
- Access tokens: 15 minutes expiration
- Refresh tokens: 7 days, rotate on each use
- Use RS256 (asymmetric) for public APIs
- Include minimal claims (no sensitive data)
- Validate signature, issuer, audience, expiration

### Middleware-Based Authentication

```typescript
// middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface JWTPayload {
  userId: string;
  email: string;
  roles: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload;
    }
  }
}

export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const payload = jwt.verify(
      token,
      process.env.JWT_PUBLIC_KEY!,
      {
        algorithms: ['RS256'],
        issuer: 'https://api.example.com',
        audience: 'https://app.example.com',
      }
    ) as JWTPayload;

    req.user = payload;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

export const authorize = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    const hasRole = roles.some(role => req.user?.roles?.includes(role));
    if (!hasRole) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
};

// Usage
router.post('/admin/users', authenticate, authorize('admin'), createUser);
```

## 6. Error Handling

### Custom Error Classes

```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public errors?: any[]) {
    super(message, 400);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super(message, 403);
  }
}
```

### Global Error Handler

```typescript
// middleware/error-handler.ts
import { Request, Response, NextFunction } from 'express';
import { AppError, ValidationError } from '../utils/errors';
import { logger } from './logger';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Operational errors (expected)
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message,
      ...(err instanceof ValidationError && { errors: err.errors })
    });
  }

  // Unexpected errors (log and hide details)
  logger.error({
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method
  });

  const message = process.env.NODE_ENV === 'production'
    ? 'Internal server error'
    : err.message;

  res.status(500).json({
    status: 'error',
    message
  });
};
```

### Structured Logging

```typescript
// middleware/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: { colorize: true }
  }
});

export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.headers['user-agent'],
      ip: req.ip
    });
  });

  next();
};
```

## 7. Frontend-Backend Handoff

### API Contract Documentation

**Create when:** Backend API is complete and ready for frontend integration.

**Template:**

```markdown
# API Handoff: User Management

## Base URL
- **Development:** `http://localhost:3000/api/v1`
- **Production:** `https://api.example.com/api/v1`

## Authentication
All endpoints require Bearer token in Authorization header:
```
Authorization: Bearer <access_token>
```

## Endpoints

### POST /users
Create a new user.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (201 Created):**
```json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2026-02-14T12:00:00Z"
}
```

**Errors:**
- `400` - Validation error (see `errors` array)
- `409` - Email already exists

### GET /users/:id
Get user by ID.

**Response (200 OK):**
```json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2026-02-14T12:00:00Z",
  "updatedAt": "2026-02-14T12:00:00Z"
}
```

**Errors:**
- `404` - User not found
- `401` - Unauthorized (invalid/missing token)

## TypeScript Types (Shared)

```typescript
export interface User {
  id: string;
  name: string;
  email: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserDTO {
  name: string;
  email: string;
  password: string;
}

export interface ErrorResponse {
  status: 'error';
  message: string;
  errors?: Array<{ field: string; message: string }>;
}
```

## Rate Limits
- General API: 100 requests/15 minutes per IP
- Auth endpoints: 5 requests/15 minutes per IP
```

### OpenAPI/Swagger Spec

```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
servers:
  - url: https://api.example.com/api/v1
paths:
  /users:
    post:
      summary: Create user
      security:
        - BearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [name, email, password]
              properties:
                name:
                  type: string
                  minLength: 1
                email:
                  type: string
                  format: email
                password:
                  type: string
                  minLength: 8
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Validation error
        '409':
          description: Email already exists
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
        createdAt:
          type: string
          format: date-time
```

## 8. Production Checklist

### Health Checks

```typescript
// Health check endpoint
app.get('/health', async (req, res) => {
  const dbHealth = await checkDatabase();
  const redisHealth = await checkRedis();

  const status = dbHealth && redisHealth ? 'ok' : 'degraded';

  res.status(status === 'ok' ? 200 : 503).json({
    status,
    timestamp: new Date().toISOString(),
    checks: {
      database: dbHealth ? 'ok' : 'down',
      redis: redisHealth ? 'ok' : 'down'
    }
  });
});

async function checkDatabase(): Promise<boolean> {
  try {
    await db.query('SELECT 1');
    return true;
  } catch {
    return false;
  }
}
```

### Graceful Shutdown

```typescript
const server = app.listen(PORT);

let isShuttingDown = false;

async function shutdown(signal: string) {
  if (isShuttingDown) return;
  isShuttingDown = true;

  console.log(`${signal} signal received: closing HTTP server`);

  server.close(async () => {
    console.log('HTTP server closed');

    // Close database connections
    await pool.end();
    console.log('Database connections closed');

    // Close Redis connection
    await redis.quit();
    console.log('Redis connection closed');

    process.exit(0);
  });

  // Force shutdown after 30 seconds
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
```

### Environment Configuration

```typescript
// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_PRIVATE_KEY: z.string(),
  JWT_PUBLIC_KEY: z.string(),
  ALLOWED_ORIGINS: z.string(),
});

export const env = envSchema.parse(process.env);
```

### CORS Configuration

```typescript
app.use(cors({
  origin: (origin, callback) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS.split(',');

    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:api:',
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

export const authLimiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:auth:',
  }),
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true,
});

// Usage
app.use('/api/', apiLimiter);
app.use('/api/v1/auth/', authLimiter);
```

### Compression

```typescript
import compression from 'compression';

app.use(compression({
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  },
  threshold: 1024, // Only compress responses > 1KB
}));
```

## 9. Common Anti-Patterns

### 1. God Controllers (Fat Controllers)

**Bad:**
```typescript
// All logic in controller
class UserController {
  async createUser(req, res) {
    // Validation
    if (!req.body.email) return res.status(400).json({ error: 'Email required' });

    // Check existing
    const existing = await db.query('SELECT * FROM users WHERE email = $1', [req.body.email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Email exists' });
    }

    // Hash password
    const hash = await bcrypt.hash(req.body.password, 10);

    // Save to DB
    const result = await db.query(
      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING *',
      [req.body.email, hash]
    );

    // Send email
    await sendEmail(req.body.email, 'Welcome!');

    res.status(201).json(result.rows[0]);
  }
}
```

**Good (Layered Architecture):**
```typescript
class UserController {
  constructor(private userService: UserService) {}

  async createUser(req, res, next) {
    try {
      const user = await this.userService.createUser(req.body);
      res.status(201).json(user);
    } catch (error) {
      next(error);
    }
  }
}
```

### 2. Business Logic in Routes

**Bad:**
```typescript
router.post('/users', async (req, res) => {
  const user = await db.users.create(req.body);
  if (user.role === 'admin') {
    await sendAdminWelcomeEmail(user.email);
  }
  res.json(user);
});
```

**Good:**
```typescript
router.post('/users', validate(createUserSchema), userController.createUser);
```

### 3. Missing Input Validation

**Bad:**
```typescript
router.post('/users', async (req, res) => {
  const user = await userService.createUser(req.body); // No validation!
  res.json(user);
});
```

**Good:**
```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  body: z.object({
    name: z.string().min(1),
    email: z.string().email(),
    password: z.string().min(8)
  })
});

router.post('/users', validate(createUserSchema), userController.createUser);
```

### 4. No Error Boundaries

**Bad:**
```typescript
router.get('/users/:id', async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  res.json(user); // What if user is null?
});
```

**Good:**
```typescript
router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  if (!user) {
    throw new NotFoundError('User not found');
  }
  res.json(user);
}));
```

### 5. Exposing Sensitive Data

**Bad:**
```typescript
router.get('/users/:id', async (req, res) => {
  const user = await db.users.findById(req.params.id);
  res.json(user); // Includes password hash!
});
```

**Good:**
```typescript
router.get('/users/:id', async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  const { password, ...safeUser } = user;
  res.json(safeUser);
});
```

## 10. Quick Reference

### HTTP Status Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input/validation error |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource conflict (duplicate) |
| 422 | Unprocessable Entity | Validation error (detailed) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |
| 503 | Service Unavailable | Temporary downtime |

### Security Headers

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
  frameguard: { action: 'deny' },
  noSniff: true,
  xssFilter: true,
}));
```

### Database Connection Pooling

```typescript
// PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: 5432,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20, // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### Transaction Pattern

```typescript
async function createOrderWithItems(orderData, items) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const orderResult = await client.query(
      'INSERT INTO orders (user_id, total) VALUES ($1, $2) RETURNING id',
      [orderData.userId, orderData.total]
    );
    const orderId = orderResult.rows[0].id;

    for (const item of items) {
      await client.query(
        'INSERT INTO order_items (order_id, product_id, quantity) VALUES ($1, $2, $3)',
        [orderId, item.productId, item.quantity]
      );
    }

    await client.query('COMMIT');
    return orderId;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
```

## Resources

- **Node.js Best Practices:** https://github.com/goldbergyoni/nodebestpractices
- **OWASP Top 10:** https://owasp.org/www-project-top-ten/
- **OAuth 2.1:** https://oauth.net/2.1/
- **FastAPI Documentation:** https://fastapi.tiangolo.com/
- **ASP.NET Core:** https://docs.microsoft.com/en-us/aspnet/core/
- **OpenAPI Specification:** https://swagger.io/specification/
- **JWT Best Practices:** https://datatracker.ietf.org/doc/html/rfc8725
