-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "auth_schema";

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "post_schema";

-- CreateEnum
CREATE TYPE "auth_schema"."Role" AS ENUM ('ADMIN', 'USER');

-- CreateTable
CREATE TABLE "auth_schema"."users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "first_name" TEXT,
    "last_name" TEXT,
    "avatar" TEXT,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "phone_number" TEXT,
    "role" "auth_schema"."Role" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_schema"."third_party_integrations" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "firebase_config" JSONB,
    "private_key" TEXT,
    "client_email" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "third_party_integrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_schema"."posts" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "images" TEXT[],
    "created_by" UUID NOT NULL,
    "updated_by" UUID,
    "deleted_by" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "posts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "auth_schema"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "third_party_integrations_project_id_key" ON "auth_schema"."third_party_integrations"("project_id");
