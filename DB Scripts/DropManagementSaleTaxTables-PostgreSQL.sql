-- ============================================================
-- Drop tables removed for clean solution (Management, Sale, Tax)
-- Database: PostgreSQL (typically lowercase table names)
-- Run against your main app database (not Auth).
-- ============================================================

-- Drop in order: child tables first (or use CASCADE - see below).
-- PostgreSQL: unquoted names are lowercased.

DROP TABLE IF EXISTS invoicedetails;
DROP TABLE IF EXISTS invoiceproductlogs;
DROP TABLE IF EXISTS invoices;

DROP TABLE IF EXISTS saledeliverydetails;
DROP TABLE IF EXISTS saledeliveries;

DROP TABLE IF EXISTS acctaxchallandetails;
DROP TABLE IF EXISTS acctaxchallans;

DROP TABLE IF EXISTS productstocks;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS customers;

DROP TABLE IF EXISTS invstorestocks;
DROP TABLE IF EXISTS invinventories;
DROP TABLE IF EXISTS stockhistorylogs;

DROP TABLE IF EXISTS fbrdatafetchlogs;

DROP TABLE IF EXISTS invoicestatuses;
DROP TABLE IF EXISTS iinvoicetypes;
DROP TABLE IF EXISTS ideliverystatuses;
DROP TABLE IF EXISTS isroitemcodes;
DROP TABLE IF EXISTS isroschedules;
DROP TABLE IF EXISTS itaxrates;
DROP TABLE IF EXISTS ireasontypes;
DROP TABLE IF EXISTS ifbrscenarios;
DROP TABLE IF EXISTS isaletypes;
DROP TABLE IF EXISTS ihscodes;
DROP TABLE IF EXISTS iunittypes;
DROP TABLE IF EXISTS icustomertypes;
DROP TABLE IF EXISTS icustregtypes;
DROP TABLE IF EXISTS istatetypes;
DROP TABLE IF EXISTS ivendortypes;

-- If you get "cannot drop because other objects depend on it", either:
-- 1) Reorder: drop tables that reference others first, or
-- 2) Use: DROP TABLE IF EXISTS tablename CASCADE;
-- (CASCADE will drop dependent foreign keys/views.)
