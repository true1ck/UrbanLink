-- ============================================================================
-- URBAN LINK - DATABASE MIGRATION SCRIPT
-- Run this on your existing Supabase database to add Urban Link tables
-- ============================================================================

-- ============================================================================
-- EXTENSIONS (Skip if already exists)
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- Note: PostGIS may need to be enabled in Supabase Dashboard > Database > Extensions
-- CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. LOOKUP TABLES
-- ============================================================================

-- Partner Tiers
CREATE TABLE IF NOT EXISTS partner_tiers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    min_verified_leads INTEGER NOT NULL,
    reward_per_lead DECIMAL(10,2) NOT NULL,
    bonus_percentage DECIMAL(5,2) DEFAULT 0,
    daily_lead_cap INTEGER DEFAULT 10,
    badge_color VARCHAR(7) DEFAULT '#22C55E',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Property Types
CREATE TABLE IF NOT EXISTS property_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    icon_name VARCHAR(50) NOT NULL,
    color_hex VARCHAR(7) DEFAULT '#2563EB',
    is_active BOOLEAN DEFAULT TRUE
);

-- Cities
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country_code VARCHAR(3) DEFAULT 'IN',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- App Config
CREATE TABLE IF NOT EXISTS app_config (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL,
    value_type VARCHAR(20) DEFAULT 'string',
    description TEXT NULL,
    updated_by_admin_id UUID NULL,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 2. ADMIN TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(30) NOT NULL CHECK (role IN ('SUPER_ADMIN', 'VERIFIER', 'FINANCE', 'SUPPORT')),
    permissions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES admins(id),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    previous_data JSONB NULL,
    new_data JSONB NULL,
    change_summary TEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 3. OWNER CONTACTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS owner_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    normalized_phone VARCHAR(15) NOT NULL,
    first_seen_at TIMESTAMP DEFAULT NOW(),
    last_seen_at TIMESTAMP DEFAULT NOW(),
    total_leads INTEGER DEFAULT 1,
    total_properties INTEGER DEFAULT 1,
    is_blacklisted BOOLEAN DEFAULT FALSE,
    blacklist_reason VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 4. MODIFY USERS TABLE (Add Urban Link columns)
-- ============================================================================

-- Add new columns to users table (if they don't exist)
DO $$ 
BEGIN
    -- Add partner_tier_id if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'partner_tier_id') THEN
        ALTER TABLE users ADD COLUMN partner_tier_id INTEGER REFERENCES partner_tiers(id) DEFAULT 1;
    END IF;
    
    -- Add referral_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'referral_code') THEN
        ALTER TABLE users ADD COLUMN referral_code VARCHAR(10) UNIQUE NULL;
    END IF;
    
    -- Add referred_by_user_id if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'referred_by_user_id') THEN
        ALTER TABLE users ADD COLUMN referred_by_user_id UUID REFERENCES users(id) NULL;
    END IF;
    
    -- Add is_phone_verified if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'is_phone_verified') THEN
        ALTER TABLE users ADD COLUMN is_phone_verified BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add profile_image_url if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'profile_image_url') THEN
        ALTER TABLE users ADD COLUMN profile_image_url VARCHAR(500) NULL;
    END IF;
    
    -- Add total_leads_submitted if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'total_leads_submitted') THEN
        ALTER TABLE users ADD COLUMN total_leads_submitted INTEGER DEFAULT 0;
    END IF;
    
    -- Add total_earnings if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'total_earnings') THEN
        ALTER TABLE users ADD COLUMN total_earnings DECIMAL(12,2) DEFAULT 0.00;
    END IF;
    
    -- Add daily_lead_cap if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'daily_lead_cap') THEN
        ALTER TABLE users ADD COLUMN daily_lead_cap INTEGER DEFAULT 10;
    END IF;
END $$;

-- ============================================================================
-- 5. AUTH SERVICE TABLES (Create if not exists)
-- ============================================================================

-- OTP Requests (rename from otp_codes if needed)
CREATE TABLE IF NOT EXISTS otp_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(255) NOT NULL,
    country_code VARCHAR(10) DEFAULT '+91',
    otp_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    attempt_count INTEGER DEFAULT 0,
    consumed_at TIMESTAMP NULL,
    deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otp_phone_expires ON otp_requests(phone_number, expires_at);
CREATE INDEX IF NOT EXISTS idx_otp_active ON otp_requests(phone_number) WHERE deleted = FALSE AND consumed_at IS NULL;

-- Refresh Tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    token_id UUID UNIQUE NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    user_agent TEXT NULL,
    ip_address VARCHAR(45) NULL,
    expires_at TIMESTAMP NOT NULL,
    last_used_at TIMESTAMP NULL,
    revoked_at TIMESTAMP NULL,
    rotated_from_id UUID NULL,
    reuse_detected_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_user_device ON refresh_tokens(user_id, device_id);
CREATE INDEX IF NOT EXISTS idx_refresh_token_id ON refresh_tokens(token_id);

-- User Devices
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_identifier VARCHAR(255) NOT NULL,
    device_platform VARCHAR(20) NOT NULL,
    device_model VARCHAR(100) NULL,
    os_version VARCHAR(50) NULL,
    app_version VARCHAR(20) NULL,
    language_code VARCHAR(10) NULL,
    timezone VARCHAR(50) NULL,
    fcm_token VARCHAR(500) NULL,
    is_emulator BOOLEAN DEFAULT FALSE,
    is_rooted BOOLEAN DEFAULT FALSE,
    is_blacklisted BOOLEAN DEFAULT FALSE,
    blacklist_reason VARCHAR(100) NULL,
    first_seen_at TIMESTAMP DEFAULT NOW(),
    last_seen_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    total_leads_from_device INTEGER DEFAULT 0,
    UNIQUE(user_id, device_identifier)
);

CREATE INDEX IF NOT EXISTS idx_device_user ON user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_device_identifier ON user_devices(device_identifier);

-- Auth Audit
CREATE TABLE IF NOT EXISTS auth_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    risk_level VARCHAR(20) DEFAULT 'INFO',
    device_id VARCHAR(255) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    meta JSONB NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_auth_audit_user ON auth_audit(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_audit_action ON auth_audit(action);

-- ============================================================================
-- 6. TRUST & FRAUD TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_trust_scores (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    trust_score INTEGER DEFAULT 100 CHECK (trust_score BETWEEN 0 AND 100),
    risk_level VARCHAR(20) DEFAULT 'LOW' CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'BLOCKED')),
    flags JSONB DEFAULT '[]',
    total_flags_ever INTEGER DEFAULT 0,
    duplicate_photo_count INTEGER DEFAULT 0,
    gps_mismatch_count INTEGER DEFAULT 0,
    rejected_leads_count INTEGER DEFAULT 0,
    last_reviewed_at TIMESTAMP NULL,
    reviewed_by_admin_id UUID REFERENCES admins(id) NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 7. WALLET TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(12,2) DEFAULT 0.00 CHECK (balance >= 0),
    lifetime_earnings DECIMAL(12,2) DEFAULT 0.00,
    total_withdrawn DECIMAL(12,2) DEFAULT 0.00,
    pending_withdrawal DECIMAL(12,2) DEFAULT 0.00,
    upi_id VARCHAR(100) NULL,
    upi_verified BOOLEAN DEFAULT FALSE,
    upi_verified_at TIMESTAMP NULL,
    bank_account_number VARCHAR(20) NULL,
    bank_ifsc VARCHAR(15) NULL,
    bank_verified BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'ON_HOLD')),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('UPI', 'BANK_TRANSFER')),
    payment_destination VARCHAR(100) NOT NULL,
    transaction_id UUID NULL,
    external_reference VARCHAR(50) NULL,
    requested_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    failure_reason TEXT NULL,
    retry_count INTEGER DEFAULT 0,
    processed_by_admin_id UUID REFERENCES admins(id)
);

-- ============================================================================
-- 8. REFERRAL TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_user_id UUID NOT NULL REFERENCES users(id),
    referred_user_id UUID NOT NULL REFERENCES users(id),
    referral_code_used VARCHAR(10) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'QUALIFIED', 'REWARDED', 'EXPIRED')),
    reward_amount DECIMAL(10,2) DEFAULT 50.00,
    reward_paid_at TIMESTAMP NULL,
    conversion_lead_id UUID NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 9. PROPERTY TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_type_id INTEGER REFERENCES property_types(id),
    purpose VARCHAR(10) NOT NULL CHECK (purpose IN ('RENT', 'SALE')),
    city_id INTEGER NOT NULL REFERENCES cities(id),
    locality VARCHAR(200) NOT NULL,
    full_address TEXT NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    owner_contact_id UUID REFERENCES owner_contacts(id),
    bhk_config VARCHAR(20) NULL,
    units_available INTEGER DEFAULT 1,
    contact_phone_from_board VARCHAR(15) NULL,
    additional_details JSONB NULL,
    is_duplicate BOOLEAN DEFAULT FALSE,
    duplicate_of_property_id UUID REFERENCES properties(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 10. REWARD RULES
-- ============================================================================

CREATE TABLE IF NOT EXISTS reward_rules (
    id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL CHECK (rule_type IN ('LEAD_REWARD', 'REFERRAL_BONUS', 'CITY_BONUS', 'PROPERTY_TYPE_BONUS', 'TIER_BONUS', 'PROMOTIONAL')),
    conditions JSONB NOT NULL,
    reward_amount DECIMAL(10,2) NOT NULL,
    bonus_percentage DECIMAL(5,2) DEFAULT 0,
    priority INTEGER DEFAULT 0,
    effective_from TIMESTAMP NOT NULL,
    effective_to TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by_admin_id UUID REFERENCES admins(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 11. LEAD TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    property_id UUID NOT NULL REFERENCES properties(id),
    device_id UUID REFERENCES user_devices(id),
    status VARCHAR(20) NOT NULL DEFAULT 'SUBMITTED' CHECK (status IN ('SUBMITTED', 'UNDER_REVIEW', 'VERIFIED', 'PAID', 'REJECTED', 'DUPLICATE')),
    reward_amount DECIMAL(10,2) NULL,
    reward_rule_id INTEGER REFERENCES reward_rules(id),
    verification_notes TEXT NULL,
    verified_at TIMESTAMP NULL,
    verified_by_admin_id UUID REFERENCES admins(id),
    paid_at TIMESTAMP NULL,
    rejection_reason VARCHAR(255) NULL,
    location_accuracy_meters DECIMAL(10,2) NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted BOOLEAN DEFAULT FALSE
);

-- Add FK for referrals.conversion_lead_id
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_referrals_lead') THEN
        ALTER TABLE referrals ADD CONSTRAINT fk_referrals_lead FOREIGN KEY (conversion_lead_id) REFERENCES leads(id);
    END IF;
END $$;

-- Transactions
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    type VARCHAR(30) NOT NULL CHECK (type IN ('LEAD_REWARD', 'REFERRAL_BONUS', 'WITHDRAWAL', 'WITHDRAWAL_REVERSAL', 'BONUS', 'ADJUSTMENT')),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    amount DECIMAL(12,2) NOT NULL,
    balance_before DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    reference_id VARCHAR(50) NULL,
    related_lead_id UUID REFERENCES leads(id),
    related_referral_id UUID REFERENCES referrals(id),
    related_withdrawal_id UUID REFERENCES withdrawal_requests(id),
    payment_method VARCHAR(20) NULL,
    payment_details JSONB NULL,
    failure_reason TEXT NULL,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    deleted BOOLEAN DEFAULT FALSE
);

-- Lead Photos
CREATE TABLE IF NOT EXISTS lead_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    photo_type VARCHAR(30) NOT NULL CHECK (photo_type IN ('PROPERTY_FACADE', 'TOLET_BOARD', 'ADDITIONAL')),
    original_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500) NULL,
    file_size_bytes INTEGER NULL,
    image_hash VARCHAR(64) NULL,
    is_ai_verified BOOLEAN DEFAULT FALSE,
    ai_quality_score DECIMAL(3,2) NULL,
    ai_detected_text TEXT NULL,
    exif_data JSONB NULL,
    upload_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Lead Status History
CREATE TABLE IF NOT EXISTS lead_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID NOT NULL REFERENCES leads(id),
    old_status VARCHAR(20) NULL,
    new_status VARCHAR(20) NOT NULL,
    changed_by_user_id UUID NULL,
    change_reason TEXT NULL,
    metadata JSONB NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 12. NOTIFICATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB NULL,
    action_url VARCHAR(500) NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    is_push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);

-- ============================================================================
-- 13. TRIGGER FUNCTIONS
-- ============================================================================

-- Auto-update timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generate referral code for new users
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
DECLARE
    new_code VARCHAR(10);
BEGIN
    IF NEW.referral_code IS NULL THEN
        LOOP
            new_code := 'REF' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
            EXIT WHEN NOT EXISTS(SELECT 1 FROM users WHERE referral_code = new_code);
        END LOOP;
        NEW.referral_code = new_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create wallet for new users
CREATE OR REPLACE FUNCTION create_wallet_for_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO wallets (id, user_id, created_at)
    VALUES (uuid_generate_v4(), NEW.id, NOW())
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trust score for new users
CREATE OR REPLACE FUNCTION create_trust_score_for_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_trust_scores (user_id, created_at)
    VALUES (NEW.id, NOW())
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 14. CREATE TRIGGERS (Drop if exists, then create)
-- ============================================================================

-- Drop triggers first to avoid duplicates
DROP TRIGGER IF EXISTS generate_referral_code_trigger ON users;
DROP TRIGGER IF EXISTS create_wallet_trigger ON users;
DROP TRIGGER IF EXISTS create_trust_score_trigger ON users;
DROP TRIGGER IF EXISTS update_users_timestamp ON users;

-- Recreate triggers
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER generate_referral_code_trigger BEFORE INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION generate_referral_code();

CREATE TRIGGER create_wallet_trigger AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_wallet_for_user();

CREATE TRIGGER create_trust_score_trigger AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_trust_score_for_user();

-- ============================================================================
-- 15. SEED DATA (Insert if not exists)
-- ============================================================================

-- Partner Tiers
INSERT INTO partner_tiers (name, min_verified_leads, reward_per_lead, bonus_percentage, daily_lead_cap, badge_color) VALUES
('Starter', 0, 50.00, 0.00, 5, '#6B7280'),
('Bronze', 10, 75.00, 5.00, 10, '#CD7F32'),
('Silver', 50, 85.00, 10.00, 15, '#C0C0C0'),
('Gold', 100, 95.00, 15.00, 20, '#FFD700'),
('Elite Partner', 250, 100.00, 20.00, 30, '#22C55E')
ON CONFLICT (name) DO NOTHING;

-- Property Types
INSERT INTO property_types (name, icon_name, color_hex) VALUES
('Flat', 'apartment', '#2563EB'),
('House', 'home', '#F97316'),
('PG / Hostel', 'bed', '#A855F7'),
('Commercial', 'store', '#22C55E')
ON CONFLICT (name) DO NOTHING;

-- Cities (Major Indian Cities)
INSERT INTO cities (name, state) 
SELECT * FROM (VALUES
    ('Mumbai', 'Maharashtra'),
    ('Delhi', 'Delhi'),
    ('Bangalore', 'Karnataka'),
    ('Hyderabad', 'Telangana'),
    ('Chennai', 'Tamil Nadu'),
    ('Kolkata', 'West Bengal'),
    ('Pune', 'Maharashtra'),
    ('Ahmedabad', 'Gujarat'),
    ('Jaipur', 'Rajasthan'),
    ('Lucknow', 'Uttar Pradesh'),
    ('Gurgaon', 'Haryana'),
    ('Noida', 'Uttar Pradesh')
) AS v(name, state)
WHERE NOT EXISTS (SELECT 1 FROM cities WHERE cities.name = v.name);

-- Default App Config
INSERT INTO app_config (key, value, value_type, description) VALUES
('MIN_WITHDRAWAL_AMOUNT', '100', 'number', 'Minimum withdrawal amount in INR'),
('MAX_DAILY_WITHDRAWALS', '3', 'number', 'Maximum withdrawal requests per day'),
('REFERRAL_REWARD_AMOUNT', '50', 'number', 'Reward for successful referral in INR'),
('LEAD_COOLDOWN_HOURS', '24', 'number', 'Hours before same phone can be submitted again'),
('APP_VERSION_ANDROID', '1.0.0', 'string', 'Current Android app version'),
('APP_VERSION_IOS', '1.0.0', 'string', 'Current iOS app version'),
('MAINTENANCE_MODE', 'false', 'boolean', 'Enable to show maintenance screen')
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- 16. CREATE WALLETS AND TRUST SCORES FOR EXISTING USERS
-- ============================================================================

-- Create wallets for any existing users who don't have one
INSERT INTO wallets (id, user_id, created_at)
SELECT uuid_generate_v4(), u.id, NOW()
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM wallets w WHERE w.user_id = u.id);

-- Create trust scores for any existing users who don't have one
INSERT INTO user_trust_scores (user_id, created_at)
SELECT u.id, NOW()
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM user_trust_scores uts WHERE uts.user_id = u.id);

-- Generate referral codes for existing users who don't have one
UPDATE users 
SET referral_code = 'REF' || UPPER(SUBSTRING(MD5(id::TEXT || RANDOM()::TEXT) FROM 1 FOR 6))
WHERE referral_code IS NULL;

-- ============================================================================
-- MIGRATION COMPLETE! ✅
-- ============================================================================
SELECT 'Migration completed successfully!' AS status;
