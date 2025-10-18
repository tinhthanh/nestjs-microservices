-- CreateTable
CREATE TABLE "third_party_integrations" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "firebase_config" JSONB,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "third_party_integrations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "third_party_integrations_project_id_key" ON "third_party_integrations"("project_id");
