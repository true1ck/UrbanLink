-- ============================================================================
-- URBAN LINK DATABASE INITIALIZATION SCRIPT
-- Version: 2.0
-- Database: PostgreSQL 15+
-- Description: Complete schema setup for Urban Link Property Rewards Platform
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. LOOKUP TABLES (No Foreign Keys)
-- ============================================================================

-- Partner Tiers
CREATE TABLE partner_tiers (
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
CREATE TABLE property_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    icon_name VARCHAR(50) NOT NULL,
    color_hex VARCHAR(7) DEFAULT '#2563EB',
    is_active BOOLEAN DEFAULT TRUE
);

-- Cities
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country_code VARCHAR(3) DEFAULT 'IN',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- App Config
CREATE TABLE app_config (
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

CREATE TABLE admins (
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

CREATE TABLE admin_activity_logs (
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
-- 3. OWNER CONTACTS (Before Properties)
-- ============================================================================

CREATE TABLE owner_contacts (
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
-- 4. USER TABLES
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    name VARCHAR(100) NULL,
    email VARCHAR(255) UNIQUE NULL,
    partner_tier_id INTEGER REFERENCES partner_tiers(id) DEFAULT 1,
    referral_code VARCHAR(10) UNIQUE NOT NULL,
    referred_by_user_id UUID REFERENCES users(id) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    profile_image_url VARCHAR(500) NULL,
    total_leads_submitted INTEGER DEFAULT 0,
    total_earnings DECIMAL(12,2) DEFAULT 0.00,
    daily_lead_cap INTEGER DEFAULT 10,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP NULL
);

CREATE TABLE user_trust_scores (
    user_id UUID PRIMARY KEY REFERENCES users(id),
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

CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    device_fingerprint VARCHAR(255) NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    device_model VARCHAR(100) NULL,
    os_version VARCHAR(50) NULL,
    app_version VARCHAR(20) NULL,
    is_emulator BOOLEAN DEFAULT FALSE,
    is_rooted BOOLEAN DEFAULT FALSE,
    is_blacklisted BOOLEAN DEFAULT FALSE,
    blacklist_reason VARCHAR(100) NULL,
    first_seen_at TIMESTAMP DEFAULT NOW(),
    last_seen_at TIMESTAMP DEFAULT NOW(),
    total_leads_from_device INTEGER DEFAULT 0
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    device_id UUID REFERENCES user_devices(id),
    platform VARCHAR(20) NOT NULL,
    fcm_token VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_activity_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE otp_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    attempts INTEGER DEFAULT 0,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- 5. WALLET & FINANCIAL TABLES
-- ============================================================================

CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id),
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

CREATE TABLE withdrawal_requests (
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
-- 6. REFERRAL TABLES
-- ============================================================================

CREATE TABLE referrals (
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
-- 7. PROPERTY TABLES
-- ============================================================================

CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_type_id INTEGER REFERENCES property_types(id),
    purpose VARCHAR(10) NOT NULL CHECK (purpose IN ('RENT', 'SALE')),
    city_id INTEGER NOT NULL REFERENCES cities(id),
    locality VARCHAR(200) NOT NULL,
    full_address TEXT NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    location_point GEOGRAPHY(POINT, 4326) NULL,
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
-- 8. REWARD RULES
-- ============================================================================

CREATE TABLE reward_rules (
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
-- 9. LEAD TABLES
-- ============================================================================

CREATE TABLE leads (
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
    submitted_from_location GEOGRAPHY(POINT, 4326) NULL,
    location_accuracy_meters DECIMAL(10,2) NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP NULL
);

-- Add FK for referrals.conversion_lead_id after leads table exists
ALTER TABLE referrals ADD CONSTRAINT fk_referrals_lead 
    FOREIGN KEY (conversion_lead_id) REFERENCES leads(id);

-- Add FK for withdrawal_requests.transaction_id after transactions table exists
CREATE TABLE transactions (
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
    deleted_at TIMESTAMP NULL
);

ALTER TABLE withdrawal_requests ADD CONSTRAINT fk_withdrawal_transaction 
    FOREIGN KEY (transaction_id) REFERENCES transactions(id);

CREATE TABLE lead_photos (
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

CREATE TABLE lead_status_history (
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
-- 10. NOTIFICATIONS
-- ============================================================================

CREATE TABLE notifications (
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

-- ============================================================================
-- 11. INDEXES
-- ============================================================================

-- Users
CREATE INDEX idx_users_phone ON users(phone_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_partner_tier ON users(partner_tier_id);
CREATE INDEX idx_users_active ON users(is_active) WHERE deleted_at IS NULL;

-- Trust Scores
CREATE INDEX idx_trust_risk ON user_trust_scores(risk_level);
CREATE INDEX idx_trust_score ON user_trust_scores(trust_score);

-- Devices
CREATE INDEX idx_device_fingerprint ON user_devices(device_fingerprint);
CREATE INDEX idx_device_user ON user_devices(user_id);
CREATE INDEX idx_device_blacklist ON user_devices(is_blacklisted) WHERE is_blacklisted = TRUE;

-- OTP
CREATE INDEX idx_otp_phone_expires ON otp_verifications(phone_number, expires_at);

-- Leads
CREATE INDEX idx_leads_user ON leads(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_status ON leads(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_created ON leads(created_at DESC);
CREATE INDEX idx_leads_device ON leads(device_id);

-- Lead Photos
CREATE INDEX idx_photos_lead ON lead_photos(lead_id);
CREATE INDEX idx_photos_hash ON lead_photos(image_hash);

-- Properties
CREATE INDEX idx_properties_city ON properties(city_id);
CREATE INDEX idx_properties_owner ON properties(owner_contact_id);
CREATE INDEX idx_properties_location ON properties USING GIST(location_point);

-- Owner Contacts
CREATE INDEX idx_owner_phone ON owner_contacts(normalized_phone);
CREATE INDEX idx_owner_blacklist ON owner_contacts(is_blacklisted);

-- Transactions
CREATE INDEX idx_transactions_wallet ON transactions(wallet_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);

-- Withdrawal Requests
CREATE INDEX idx_withdrawal_wallet ON withdrawal_requests(wallet_id);
CREATE INDEX idx_withdrawal_status ON withdrawal_requests(status);
CREATE INDEX idx_withdrawal_requested ON withdrawal_requests(requested_at DESC);

-- Referrals
CREATE INDEX idx_referrals_referrer ON referrals(referrer_user_id);
CREATE INDEX idx_referrals_referred ON referrals(referred_user_id);
CREATE INDEX idx_referrals_status ON referrals(status);

-- Admin Logs
CREATE INDEX idx_admin_logs_admin ON admin_activity_logs(admin_id);
CREATE INDEX idx_admin_logs_entity ON admin_activity_logs(entity_type, entity_id);
CREATE INDEX idx_admin_logs_action ON admin_activity_logs(action);
CREATE INDEX idx_admin_logs_created ON admin_activity_logs(created_at DESC);

-- Reward Rules
CREATE INDEX idx_rules_active ON reward_rules(is_active, effective_from, effective_to);
CREATE INDEX idx_rules_type ON reward_rules(rule_type);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- ============================================================================
-- 12. TRIGGER FUNCTIONS
-- ============================================================================

-- Auto-update timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Lead status change tracking
CREATE OR REPLACE FUNCTION track_lead_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO lead_status_history (id, lead_id, old_status, new_status, created_at)
        VALUES (uuid_generate_v4(), NEW.id, OLD.status, NEW.status, NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Wallet balance update (race-condition safe)
CREATE OR REPLACE FUNCTION update_wallet_on_transaction()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'COMPLETED' AND OLD.status != 'COMPLETED' THEN
        IF NEW.type IN ('LEAD_REWARD', 'REFERRAL_BONUS', 'BONUS') THEN
            UPDATE wallets SET
                balance = balance + NEW.amount,
                lifetime_earnings = lifetime_earnings + NEW.amount,
                updated_at = NOW()
            WHERE id = NEW.wallet_id;
        ELSIF NEW.type = 'WITHDRAWAL' THEN
            UPDATE wallets SET
                pending_withdrawal = pending_withdrawal - NEW.amount,
                total_withdrawn = total_withdrawn + NEW.amount,
                updated_at = NOW()
            WHERE id = NEW.wallet_id;
        ELSIF NEW.type = 'WITHDRAWAL_REVERSAL' THEN
            UPDATE wallets SET
                balance = balance + NEW.amount,
                pending_withdrawal = pending_withdrawal - NEW.amount,
                updated_at = NOW()
            WHERE id = NEW.wallet_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trust score auto-update
CREATE OR REPLACE FUNCTION update_trust_on_lead_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'REJECTED' AND OLD.status != 'REJECTED' THEN
        UPDATE user_trust_scores SET
            rejected_leads_count = rejected_leads_count + 1,
            trust_score = GREATEST(0, trust_score - 5),
            risk_level = CASE
                WHEN trust_score - 5 <= 30 THEN 'HIGH'
                WHEN trust_score - 5 <= 60 THEN 'MEDIUM'
                ELSE 'LOW'
            END,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    ELSIF NEW.status = 'PAID' AND OLD.status != 'PAID' THEN
        UPDATE user_trust_scores SET
            trust_score = LEAST(100, trust_score + 1),
            risk_level = CASE
                WHEN trust_score + 1 >= 70 THEN 'LOW'
                WHEN trust_score + 1 >= 40 THEN 'MEDIUM'
                ELSE 'HIGH'
            END,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Owner contact upsert
CREATE OR REPLACE FUNCTION upsert_owner_contact()
RETURNS TRIGGER AS $$
DECLARE
    owner_id UUID;
    normalized_phone VARCHAR(15);
BEGIN
    IF NEW.contact_phone_from_board IS NOT NULL THEN
        normalized_phone := REGEXP_REPLACE(NEW.contact_phone_from_board, '[^0-9]', '', 'g');
        normalized_phone := RIGHT(normalized_phone, 10);
        
        INSERT INTO owner_contacts (id, phone_number, normalized_phone)
        VALUES (uuid_generate_v4(), NEW.contact_phone_from_board, normalized_phone)
        ON CONFLICT (phone_number) DO UPDATE SET
            last_seen_at = NOW(),
            total_leads = owner_contacts.total_leads + 1
        RETURNING id INTO owner_id;
        
        NEW.owner_contact_id = owner_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trust score initialization
CREATE OR REPLACE FUNCTION create_trust_score_for_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_trust_scores (user_id, created_at)
    VALUES (NEW.id, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Wallet creation
CREATE OR REPLACE FUNCTION create_wallet_for_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO wallets (id, user_id, created_at)
    VALUES (uuid_generate_v4(), NEW.id, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Referral code generation
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

-- Notification on lead status
CREATE OR REPLACE FUNCTION notify_user_on_lead_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'VERIFIED' AND OLD.status != 'VERIFIED' THEN
        INSERT INTO notifications (id, user_id, type, title, message, metadata)
        VALUES (uuid_generate_v4(), NEW.user_id, 'LEAD_VERIFIED',
            'Lead Verified! 🎉', 'Your lead has been verified. Reward will be credited soon.',
            jsonb_build_object('lead_id', NEW.id));
    ELSIF NEW.status = 'REJECTED' AND OLD.status != 'REJECTED' THEN
        INSERT INTO notifications (id, user_id, type, title, message, metadata)
        VALUES (uuid_generate_v4(), NEW.user_id, 'LEAD_REJECTED',
            'Lead Not Accepted', COALESCE('Reason: ' || NEW.rejection_reason, 'Your lead could not be verified.'),
            jsonb_build_object('lead_id', NEW.id));
    ELSIF NEW.status = 'PAID' AND OLD.status != 'PAID' THEN
        INSERT INTO notifications (id, user_id, type, title, message, metadata)
        VALUES (uuid_generate_v4(), NEW.user_id, 'PAYOUT_COMPLETED',
            'Reward Credited! 💰', '₹' || NEW.reward_amount::TEXT || ' has been added to your wallet.',
            jsonb_build_object('lead_id', NEW.id, 'amount', NEW.reward_amount));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Device lead counter
CREATE OR REPLACE FUNCTION increment_device_lead_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.device_id IS NOT NULL THEN
        UPDATE user_devices SET
            total_leads_from_device = total_leads_from_device + 1,
            last_seen_at = NOW()
        WHERE id = NEW.device_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Withdrawal to transaction
CREATE OR REPLACE FUNCTION create_transaction_for_withdrawal()
RETURNS TRIGGER AS $$
DECLARE
    wallet_balance DECIMAL(12,2);
    new_transaction_id UUID;
BEGIN
    IF NEW.status = 'PROCESSING' AND OLD.status = 'REQUESTED' THEN
        SELECT balance INTO wallet_balance FROM wallets WHERE id = NEW.wallet_id FOR UPDATE;
        
        new_transaction_id := uuid_generate_v4();
        
        INSERT INTO transactions (
            id, wallet_id, type, status, amount, 
            balance_before, balance_after, related_withdrawal_id, payment_method
        ) VALUES (
            new_transaction_id, NEW.wallet_id, 'WITHDRAWAL', 'PROCESSING',
            NEW.amount, wallet_balance, wallet_balance - NEW.amount,
            NEW.id, NEW.payment_method
        );
        
        NEW.transaction_id = new_transaction_id;
        
        UPDATE wallets SET
            balance = balance - NEW.amount,
            pending_withdrawal = pending_withdrawal + NEW.amount,
            updated_at = NOW()
        WHERE id = NEW.wallet_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Referral reward processing
CREATE OR REPLACE FUNCTION process_referral_on_first_lead()
RETURNS TRIGGER AS $$
DECLARE
    referral_record RECORD;
    referrer_wallet_id UUID;
BEGIN
    IF NEW.status = 'PAID' AND OLD.status != 'PAID' THEN
        SELECT r.* INTO referral_record
        FROM referrals r
        WHERE r.referred_user_id = NEW.user_id AND r.status = 'PENDING'
        LIMIT 1;
        
        IF FOUND THEN
            SELECT id INTO referrer_wallet_id FROM wallets
            WHERE user_id = referral_record.referrer_user_id;
            
            UPDATE referrals SET status = 'QUALIFIED', conversion_lead_id = NEW.id
            WHERE id = referral_record.id;
            
            INSERT INTO transactions (
                id, wallet_id, type, status, amount,
                balance_before, balance_after, related_referral_id
            )
            SELECT uuid_generate_v4(), referrer_wallet_id, 'REFERRAL_BONUS', 'COMPLETED',
                   referral_record.reward_amount, w.balance, w.balance + referral_record.reward_amount,
                   referral_record.id
            FROM wallets w WHERE w.id = referrer_wallet_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- User stats denormalization
CREATE OR REPLACE FUNCTION update_user_stats_on_lead()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'PAID' AND OLD.status != 'PAID' THEN
        UPDATE users SET
            total_leads_submitted = total_leads_submitted + 1,
            total_earnings = total_earnings + COALESCE(NEW.reward_amount, 0),
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 13. CREATE TRIGGERS
-- ============================================================================

-- Timestamp triggers
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER update_leads_timestamp BEFORE UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER update_wallets_timestamp BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER update_trust_timestamp BEFORE UPDATE ON user_trust_scores
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- User creation triggers
CREATE TRIGGER generate_referral_code_trigger BEFORE INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION generate_referral_code();
CREATE TRIGGER create_wallet_trigger AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_wallet_for_user();
CREATE TRIGGER create_trust_score_trigger AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_trust_score_for_user();

-- Lead triggers
CREATE TRIGGER lead_status_change_trigger AFTER UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION track_lead_status_change();
CREATE TRIGGER lead_notification_trigger AFTER UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION notify_user_on_lead_status();
CREATE TRIGGER trust_score_trigger AFTER UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION update_trust_on_lead_status();
CREATE TRIGGER user_stats_trigger AFTER UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION update_user_stats_on_lead();
CREATE TRIGGER referral_reward_trigger AFTER UPDATE ON leads
    FOR EACH ROW EXECUTE FUNCTION process_referral_on_first_lead();
CREATE TRIGGER device_lead_count_trigger AFTER INSERT ON leads
    FOR EACH ROW EXECUTE FUNCTION increment_device_lead_count();

-- Property triggers
CREATE TRIGGER owner_contact_trigger BEFORE INSERT ON properties
    FOR EACH ROW EXECUTE FUNCTION upsert_owner_contact();

-- Transaction triggers
CREATE TRIGGER wallet_balance_trigger AFTER UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_wallet_on_transaction();

-- Withdrawal triggers
CREATE TRIGGER withdrawal_transaction_trigger BEFORE UPDATE ON withdrawal_requests
    FOR EACH ROW EXECUTE FUNCTION create_transaction_for_withdrawal();

-- ============================================================================
-- 14. VIEWS
-- ============================================================================

CREATE VIEW vw_leads_with_trust AS
SELECT 
    l.*, u.name AS submitter_name, u.phone_number,
    uts.trust_score, uts.risk_level,
    p.locality, c.name AS city,
    pt.name AS property_type
FROM leads l
JOIN users u ON l.user_id = u.id
JOIN user_trust_scores uts ON u.id = uts.user_id
JOIN properties p ON l.property_id = p.id
JOIN cities c ON p.city_id = c.id
JOIN property_types pt ON p.property_type_id = pt.id
WHERE l.deleted_at IS NULL;

CREATE VIEW vw_user_dashboard AS
SELECT 
    u.id, u.name, u.phone_number,
    pt.name AS partner_tier,
    uts.trust_score, uts.risk_level,
    w.balance, w.pending_withdrawal,
    u.total_leads_submitted, u.total_earnings,
    (SELECT COUNT(*) FROM leads WHERE user_id = u.id AND status = 'SUBMITTED') AS pending_leads,
    (SELECT COUNT(*) FROM referrals WHERE referrer_user_id = u.id AND status = 'REWARDED') AS successful_referrals,
    (SELECT COUNT(*) FROM notifications WHERE user_id = u.id AND is_read = FALSE) AS unread_notifications
FROM users u
JOIN partner_tiers pt ON u.partner_tier_id = pt.id
JOIN wallets w ON u.id = w.user_id
JOIN user_trust_scores uts ON u.id = uts.user_id
WHERE u.deleted_at IS NULL;

-- ============================================================================
-- 15. SEED DATA
-- ============================================================================

-- Partner Tiers
INSERT INTO partner_tiers (name, min_verified_leads, reward_per_lead, bonus_percentage, daily_lead_cap, badge_color) VALUES
('Starter', 0, 50.00, 0.00, 5, '#6B7280'),
('Bronze', 10, 75.00, 5.00, 10, '#CD7F32'),
('Silver', 50, 85.00, 10.00, 15, '#C0C0C0'),
('Gold', 100, 95.00, 15.00, 20, '#FFD700'),
('Elite Partner', 250, 100.00, 20.00, 30, '#22C55E');

-- Property Types
INSERT INTO property_types (name, icon_name, color_hex) VALUES
('Flat', 'apartment', '#2563EB'),
('House', 'home', '#F97316'),
('PG / Hostel', 'bed', '#A855F7'),
('Commercial', 'store', '#22C55E');

-- Cities (Major Indian Cities)
INSERT INTO cities (name, state) VALUES
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
('Noida', 'Uttar Pradesh');

-- Default App Config
INSERT INTO app_config (key, value, value_type, description) VALUES
('min_withdrawal_amount', '100', 'number', 'Minimum withdrawal amount in INR'),
('max_daily_leads', '10', 'number', 'Default max leads per day'),
('referral_reward_amount', '50', 'number', 'Referral reward in INR'),
('otp_expiry_seconds', '45', 'number', 'OTP expiry time in seconds'),
('payout_processing_days', '2', 'number', 'Days to process payout'),
('app_maintenance_mode', 'false', 'boolean', 'App maintenance mode flag');

-- Default Admin (password: admin123)
INSERT INTO admins (id, email, password_hash, name, role) VALUES
(uuid_generate_v4(), 'admin@urbanlink.com', '$2a$10$rQnM8xUMhWV8v6VLP8LUxuKJdJxfmWr2QHZqQI3CnxWC8XBXL5qNK', 'Super Admin', 'SUPER_ADMIN');

-- Default Reward Rule
INSERT INTO reward_rules (rule_name, rule_type, conditions, reward_amount, effective_from, is_active) VALUES
('Default Lead Reward', 'LEAD_REWARD', '{}', 100.00, NOW(), TRUE),
('Referral Bonus', 'REFERRAL_BONUS', '{}', 50.00, NOW(), TRUE);

-- ============================================================================
-- 16. ROW-LEVEL SECURITY (Optional - Enable if using Supabase/Postgres RLS)
-- ============================================================================

-- Uncomment below if you want to enable RLS
/*
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY leads_user_access ON leads
    FOR ALL USING (user_id = current_setting('app.current_user_id')::UUID);

CREATE POLICY transactions_user_access ON transactions
    FOR SELECT USING (
        wallet_id IN (SELECT id FROM wallets WHERE user_id = current_setting('app.current_user_id')::UUID)
    );

CREATE POLICY wallets_user_access ON wallets
    FOR ALL USING (user_id = current_setting('app.current_user_id')::UUID);

CREATE POLICY notifications_user_access ON notifications
    FOR ALL USING (user_id = current_setting('app.current_user_id')::UUID);
*/

-- ============================================================================
-- INITIALIZATION COMPLETE
-- ============================================================================

SELECT 'Urban Link Database initialized successfully!' AS status;
