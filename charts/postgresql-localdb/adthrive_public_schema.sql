--
-- PostgreSQL database dump 2022-11-01
--

-- Dumped from database version 11.8
-- Dumped by pg_dump version 11.8 (Debian 11.8-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: adthrive; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE adthrive WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect adthrive
create extension "uuid-ossp"; create extension "pg_buffercache";

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--



--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: site_ad_density_device; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.site_ad_density_device AS ENUM (
    'mobile',
    'desktop'
);


--
-- Name: generate_object_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_object_id() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
        DECLARE
            time_component bigint;
            machine_id bigint := FLOOR(random() * 16777215);
            process_id bigint;
            seq_id bigint := FLOOR(random() * 16777215);
            result varchar:= '';
        BEGIN
            SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp())) INTO time_component;
            SELECT pg_backend_pid() INTO process_id;

            result := result || lpad(to_hex(time_component), 8, '0');
            result := result || lpad(to_hex(machine_id), 6, '0');
            result := result || lpad(to_hex(process_id), 4, '0');
            result := result || lpad(to_hex(seq_id), 6, '0');
            RETURN result;
        END;
        $$;


--
-- Name: on_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.on_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF OLD IS DISTINCT FROM NEW THEN
            NEW.updated_at := NOW();
          END IF;

          RETURN NEW;
        END;
        $$;


--
-- Name: pg_stat_activity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pg_stat_activity() RETURNS SETOF pg_stat_activity
    LANGUAGE sql SECURITY DEFINER
    AS $$ SELECT * from pg_catalog.pg_stat_activity; $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_organization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_organization (
    account_id numeric NOT NULL,
    organization_id character varying(24),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: active_campaign_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_campaign_config (
    base_id_config json NOT NULL,
    field_id_config json NOT NULL,
    tag_id_config json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    account_field_id_config json
);


--
-- Name: ad_code_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_code_config (
    id integer NOT NULL,
    ad_code_config_type character varying(25) NOT NULL,
    uploaded_by_user_id character varying(255) NOT NULL,
    "values" json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    major_minor_version character varying(10) DEFAULT '1.0'::character varying NOT NULL,
    patch_version smallint DEFAULT 0 NOT NULL
);


--
-- Name: ad_code_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ad_code_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ad_code_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ad_code_config_id_seq OWNED BY public.ad_code_config.id;


--
-- Name: ad_host; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_host (
    site_id character varying(255) NOT NULL,
    host json
);


--
-- Name: ad_layout_published; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_layout_published (
    site_id character varying(255) NOT NULL,
    layout json,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: ad_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_location (
    id character varying(255) NOT NULL,
    name character varying(255),
    description character varying(255),
    inactive boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: ad_location_ad_size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_location_ad_size (
    ad_location_id character varying(255) NOT NULL,
    ad_size_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: ad_network_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_network_device (
    id character varying(255) NOT NULL,
    ad_network_id character varying(255) NOT NULL,
    device_id character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ad_page_campaign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_page_campaign (
    url character varying(3000) NOT NULL,
    campaigns json
);


--
-- Name: ad_partner; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_partner (
    id integer NOT NULL,
    key text NOT NULL,
    name text NOT NULL,
    display_available boolean DEFAULT false NOT NULL,
    video_available boolean DEFAULT false NOT NULL,
    display_enabled_default boolean DEFAULT false NOT NULL,
    video_enabled_default boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: ad_partner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ad_partner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ad_partner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ad_partner_id_seq OWNED BY public.ad_partner.id;


--
-- Name: ad_size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_size (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    width integer,
    height integer,
    inactive boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_featured boolean DEFAULT false NOT NULL
);


--
-- Name: ad_unit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_unit (
    id character varying(255) NOT NULL,
    "group" character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_default boolean DEFAULT false,
    parent_id character varying(25)
);


--
-- Name: ad_unit_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_unit_1 (
    id character varying(255),
    name character varying(255)
);


--
-- Name: ad_unit_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ad_unit_temp (
    id character varying(255) NOT NULL,
    "group" character varying(255)
);


--
-- Name: adlocationsequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.adlocationsequence
    START WITH 28
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: adlocationsequence; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.adlocationsequence OWNED BY public.ad_location.id;


--
-- Name: adthrive_dfp_bucket_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_bucket_earning (
    date date NOT NULL,
    site_id character varying(25),
    ad_unit_1 character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_1_id character varying(25) NOT NULL,
    ad_unit_2_id character varying(25) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    device character varying(25) NOT NULL,
    bucket character varying(25) NOT NULL,
    clicks integer,
    gross_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    unfilled_impressions integer,
    code_served integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    impression_opportunities integer
);


--
-- Name: adthrive_dfp_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_earning (
    date date NOT NULL,
    site_id character varying(255),
    ad_network_id character varying(255),
    order_name character varying(255) NOT NULL,
    order_group character varying(255),
    ad_unit_1 character varying(255) NOT NULL,
    ad_unit_2 character varying(255) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    apply_adthrive_media_rev_share boolean,
    apply_adthrive_custom_video_player_rev_share boolean,
    rev_share integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    programmatic_guaranteed boolean,
    order_id bigint,
    ad_unit_1_id character varying(255),
    ad_unit_2_id character varying(255),
    cam_client_direct boolean,
    cam_client_pmp boolean
);


--
-- Name: adthrive_dfp_earning_2020_04_17; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_earning_2020_04_17 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    order_name character varying(255),
    order_group character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    apply_adthrive_media_rev_share boolean,
    apply_adthrive_custom_video_player_rev_share boolean,
    rev_share integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    programmatic_guaranteed boolean,
    order_id bigint,
    ad_unit_1_id character varying(255),
    ad_unit_2_id character varying(255),
    cam_client_direct boolean,
    cam_client_pmp boolean
);


--
-- Name: adthrive_dfp_earning_2020_08_29; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_earning_2020_08_29 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    order_name character varying(255),
    order_group character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    apply_adthrive_media_rev_share boolean,
    apply_adthrive_custom_video_player_rev_share boolean,
    rev_share integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    programmatic_guaranteed boolean,
    order_id bigint,
    ad_unit_1_id character varying(255),
    ad_unit_2_id character varying(255),
    cam_client_direct boolean,
    cam_client_pmp boolean
);


--
-- Name: adthrive_dfp_earning_dimension; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_earning_dimension (
    date date NOT NULL,
    site_id character varying(255),
    ad_network_id character varying(255),
    order_name character varying(255) NOT NULL,
    ad_unit_1 character varying(255) NOT NULL,
    ad_unit_2 character varying(255) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    dimension character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    measurable_impression_rate numeric(12,2),
    viewable_impression_rate numeric(12,2),
    apply_adthrive_media_rev_share boolean,
    apply_adthrive_custom_video_player_rev_share boolean,
    rev_share integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: adthrive_dfp_earning_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_earning_temp (
    date date NOT NULL,
    site_id character varying(255),
    ad_network_id character varying(255),
    order_name character varying(255) NOT NULL,
    order_group character varying(255),
    ad_unit_1 character varying(255) NOT NULL,
    ad_unit_2 character varying(255) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    apply_adthrive_media_rev_share boolean,
    apply_adthrive_custom_video_player_rev_share boolean,
    rev_share integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    programmatic_guaranteed boolean,
    order_id bigint,
    ad_unit_1_id character varying(255),
    ad_unit_2_id character varying(255),
    cam_client_direct boolean,
    cam_client_pmp boolean
);


--
-- Name: adthrive_dfp_impression_device_dimension; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_impression_device_dimension (
    date date NOT NULL,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit_1 character varying(255) NOT NULL,
    ad_unit_2 character varying(255) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    dimension character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    measurable_impression_rate numeric(12,2),
    viewable_impression_rate numeric(12,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: adthrive_dfp_refresh_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_dfp_refresh_earning (
    date date NOT NULL,
    site_id character varying(25),
    ad_unit_1 character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_1_id character varying(25) NOT NULL,
    ad_unit_2_id character varying(25) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    device character varying(25) NOT NULL,
    refresh character varying(5) NOT NULL,
    clicks integer,
    gross_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: adthrive_gam_adx_deals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_adx_deals (
    date date NOT NULL,
    site_id character varying(25),
    ad_unit_1_id character varying(25),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(25),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    advertiser_name character varying(255) NOT NULL,
    device character varying(25) NOT NULL,
    deal_id character varying(255) NOT NULL,
    deal_name character varying(255),
    estimated_revenue numeric(12,6),
    clicks integer,
    impressions integer,
    active_view_enabled_impressions integer,
    active_view_measured_impressions integer,
    active_view_viewed_impressions integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: adthrive_gam_adx_deals_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_adx_deals_temp (
    date date NOT NULL,
    site_id character varying(25),
    ad_unit_1_id character varying(25) NOT NULL,
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(25) NOT NULL,
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255) NOT NULL,
    advertiser_name character varying(255) NOT NULL,
    device character varying(25) NOT NULL,
    deal_id character varying(255) NOT NULL,
    deal_name character varying(255),
    estimated_revenue numeric(12,6),
    clicks integer,
    impressions integer,
    active_view_enabled_impressions integer,
    active_view_measured_impressions integer,
    active_view_viewed_impressions integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: adthrive_gam_by_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_by_source (
    date date NOT NULL,
    site_id character varying(25),
    ad_unit_1 character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_1_id character varying(25) NOT NULL,
    ad_unit_2_id character varying(25) NOT NULL,
    ad_unit_code character varying(255) NOT NULL,
    referrer character varying(255) NOT NULL,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: adthrive_gam_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning (
    date date NOT NULL,
    site_id character varying(25),
    ad_network_id character varying(25) DEFAULT ''::character varying NOT NULL,
    ad_unit_1_id character varying(255) NOT NULL,
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255) NOT NULL,
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    adblock_recovery character varying(50) NOT NULL,
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    unfilled_impressions integer,
    impression_opportunities integer,
    clicks integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: adthrive_gam_earning_2020_04_05; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_2020_04_05 (
    date date,
    site_id character varying(25),
    ad_network_id character varying(25),
    ad_unit_1_id character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    adblock_publica character varying(50),
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: adthrive_gam_earning_2020_04_17; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_2020_04_17 (
    date date,
    site_id character varying(25),
    ad_network_id character varying(25),
    ad_unit_1_id character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    adblock_publica character varying(50),
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: adthrive_gam_earning_2020_05_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_2020_05_23 (
    date date,
    site_id character varying(25),
    ad_network_id character varying(25),
    ad_unit_1_id character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    adblock_publica character varying(50),
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: adthrive_gam_earning_2020_06_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_2020_06_01 (
    date date,
    site_id character varying(25),
    ad_network_id character varying(25),
    ad_unit_1_id character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    adblock_publica character varying(50),
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: adthrive_gam_earning_2020_08_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_2020_08_02 (
    date date,
    site_id character varying(25),
    ad_network_id character varying(25),
    ad_unit_1_id character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    adblock_publica character varying(50),
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: adthrive_gam_earning_2020_08_29; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_2020_08_29 (
    date date,
    site_id character varying(25),
    ad_network_id character varying(25),
    ad_unit_1_id character varying(255),
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255),
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255),
    device character varying(255),
    adblock_publica character varying(50),
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: adthrive_gam_earning_old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gam_earning_old (
    date date NOT NULL,
    site_id character varying(25),
    ad_network_id character varying(25) DEFAULT ''::character varying NOT NULL,
    ad_unit_1_id character varying(255) NOT NULL,
    ad_unit_1 character varying(255),
    ad_unit_2_id character varying(255) NOT NULL,
    ad_unit_2 character varying(255),
    ad_unit_code character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    adblock_publica character varying(50) NOT NULL,
    gross_earnings numeric(12,6),
    adjusted_gross_earnings numeric(12,6),
    publisher_earnings numeric(12,6),
    impressions integer,
    eligible_impressions integer,
    measurable_impressions integer,
    viewable_impressions integer,
    clicks integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: adthrive_gamlog_by_page_path; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gamlog_by_page_path (
    date date NOT NULL,
    site_id character varying(25) NOT NULL,
    page_path text NOT NULL,
    impressions integer,
    gross_revenue numeric(40,20),
    clean_page_path text,
    measurable_impressions integer,
    viewable_impressions integer,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: adthrive_gum_gum_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_gum_gum_earning (
    date date NOT NULL,
    site_id character varying(255),
    device character varying(255) NOT NULL,
    zone_id character varying(255) NOT NULL,
    zone_name character varying(255),
    impressions integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    rev_share integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: adthrive_sekindo_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adthrive_sekindo_earning (
    date date NOT NULL,
    site_id character varying(255),
    sub_id character varying(255) NOT NULL,
    space_name character varying(255) NOT NULL,
    device_type character varying(255) NOT NULL,
    unique_impressions integer,
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,2),
    earnings numeric(12,6),
    rev_share integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ad_server_impressions integer,
    ad_server_earnings numeric(12,2)
);


--
-- Name: alert; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    alert_type_id integer NOT NULL,
    alert_distribution_type_id integer NOT NULL,
    body text NOT NULL,
    publishes_at timestamp with time zone,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    closeable boolean DEFAULT false NOT NULL
);


--
-- Name: alert_distribution_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_distribution_type (
    id integer NOT NULL,
    name character varying(25) NOT NULL
);


--
-- Name: alert_distribution_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_distribution_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_distribution_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_distribution_type_id_seq OWNED BY public.alert_distribution_type.id;


--
-- Name: alert_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_id_seq OWNED BY public.alert.id;


--
-- Name: alert_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_type (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    priority integer NOT NULL
);


--
-- Name: alert_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_type_id_seq OWNED BY public.alert_type.id;


--
-- Name: application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application (
    id character varying(255) NOT NULL,
    site_id character varying(255),
    name character varying(255),
    email character varying(255),
    site_name character varying(255),
    site_url character varying(255),
    pageviews integer,
    status character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    google_analytics_email character varying(255),
    google_analytics_access_token character varying(255),
    google_analytics_refresh_token character varying(255)
);


--
-- Name: application_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_account (
    application_id character varying(255) NOT NULL,
    account_id character varying(255) NOT NULL,
    account_name character varying(255),
    web_property_id character varying(255) NOT NULL,
    web_property_name character varying(255),
    profile_id character varying(255) NOT NULL,
    profile_name character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_ad_network; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_ad_network (
    id integer NOT NULL,
    application_id character varying(255),
    name character varying(255),
    status character varying(255)
);


--
-- Name: application_ad_network_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_ad_network_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_ad_network_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_ad_network_id_seq OWNED BY public.application_ad_network.id;


--
-- Name: application_analytic_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_analytic_account (
    application_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_analytic_account_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_analytic_account_country (
    application_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    country character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_analytic_account_device_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_analytic_account_device_category (
    application_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    device_category character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_analytic_account_page_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_analytic_account_page_title (
    application_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    page_title character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_analytic_account_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_analytic_account_source (
    application_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    source character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: brief_performance_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brief_performance_summary (
    brief_id character varying(24) NOT NULL,
    site_id character varying(24) NOT NULL,
    publish_date date NOT NULL,
    search_pv_delta integer,
    search_pv_delta_classification character varying,
    position_delta numeric,
    position_delta_classification character varying
);


--
-- Name: calendar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar (
    id date NOT NULL,
    year integer,
    month integer,
    day integer,
    day_of_week integer,
    day_of_year integer,
    quarter integer,
    week integer,
    day_name character varying(255),
    month_name character varying(255),
    first_day_of_month date,
    last_day_of_month date,
    is_first_day_of_month boolean,
    is_last_day_of_month boolean
);


--
-- Name: change_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_history (
    id bigint NOT NULL,
    entity_type character varying(50),
    entity_id character varying(25),
    before jsonb,
    after jsonb,
    user_id character varying(25),
    "timestamp" timestamp with time zone DEFAULT now(),
    action character varying(255) DEFAULT 'UPDATE'::character varying NOT NULL
);


--
-- Name: change_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_history_id_seq OWNED BY public.change_history.id;


--
-- Name: data_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_source (
    id character varying(255) NOT NULL,
    type character varying(255),
    name character varying(255),
    inactive boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    on_application boolean DEFAULT false
);


--
-- Name: site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(100),
    url character varying(255),
    start_date date,
    install_date date,
    dashboard_start_date date,
    rev_share integer DEFAULT 75,
    rev_share_video integer DEFAULT 75,
    rev_share_in_image integer DEFAULT 75,
    service character varying(255),
    status character varying(255),
    version character varying(255),
    breakpoint_tablet integer DEFAULT 962,
    breakpoint_desktop integer DEFAULT 1024,
    ad_manager character varying(255),
    ad_options json,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    in_image_zone character varying(255),
    velocity boolean,
    velocity_start_date date,
    velocity_cost numeric(12,6),
    jw boolean,
    jw_api_key character varying(255),
    jw_api_secret character varying(255),
    video_embed character varying(255),
    jw_property_id character varying(255),
    jw_player_id character varying(255),
    ads_txt text,
    gam character varying(255),
    tier character varying(32),
    video_default_player_type character varying(32),
    dropped_reason_id integer,
    override_embed_location boolean DEFAULT false NOT NULL,
    autoplay_collapsible_enabled boolean DEFAULT false NOT NULL,
    company_name text,
    ad_types json,
    video_ad_options json,
    non_standard_reason text,
    previous_ad_network character varying,
    ad_locations json,
    targeting text,
    jw_playlist_id character varying(20),
    footer_selector text,
    jw_collapsible_player_id character varying(20),
    organization_id character varying(255),
    ad_code_beta_tester boolean DEFAULT false NOT NULL,
    include_manager_domain boolean DEFAULT true NOT NULL,
    has_dropped_access boolean DEFAULT false NOT NULL
);


--
-- Name: cmi_revenue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cmi_revenue AS
 WITH revenue AS (
         SELECT earning.date,
            source.name AS source,
            (earning.gross_earnings - earning.earnings) AS net_revenue,
            earning.gross_earnings AS gross_revenue
           FROM ((public.adthrive_dfp_earning earning
             JOIN public.data_source source ON (((source.id)::text = (earning.ad_network_id)::text)))
             JOIN public.site ON (((site.id)::text = (earning.site_id)::text)))
          WHERE ((earning.ad_network_id)::text = ANY (ARRAY[('52e72f29208f222c05b99d99'::character varying)::text, ('5750646c4c854b2213f77f5f'::character varying)::text]))
        UNION ALL
         SELECT earning.date,
            'AdThrive In Image Ads'::character varying AS source,
            (earning.gross_earnings - earning.earnings) AS net_revenue,
            earning.gross_earnings AS gross_revenue
           FROM (public.adthrive_gum_gum_earning earning
             JOIN public.site ON ((((site.id)::text = (earning.site_id)::text) AND ((site.status)::text = 'Active'::text))))
        UNION ALL
         SELECT earning.date,
            'Custom Video Player'::character varying AS source,
            (earning.gross_earnings - earning.earnings) AS net_revenue,
            earning.gross_earnings AS gross_revenue
           FROM (public.adthrive_sekindo_earning earning
             JOIN public.site ON ((((site.id)::text = (earning.site_id)::text) AND ((site.status)::text = 'Active'::text))))
        )
 SELECT revenue.date,
    sum(
        CASE
            WHEN ((revenue.source)::text = 'AdThrive In Image Ads'::text) THEN revenue.net_revenue
            ELSE (0)::numeric
        END) AS net_gum_gum_revenue,
    sum(
        CASE
            WHEN ((revenue.source)::text = 'Custom Video Player'::text) THEN revenue.net_revenue
            ELSE (0)::numeric
        END) AS net_video_revenue,
    sum(
        CASE
            WHEN ((revenue.source)::text = 'AdThrive Media'::text) THEN revenue.net_revenue
            ELSE (0)::numeric
        END) AS net_adthrive_revenue,
    sum(revenue.net_revenue) AS total_net_revenue,
    sum(
        CASE
            WHEN ((revenue.source)::text = 'AdThrive In Image Ads'::text) THEN revenue.gross_revenue
            ELSE (0)::numeric
        END) AS gross_gum_gum_revenue,
    sum(
        CASE
            WHEN ((revenue.source)::text = 'Custom Video Player'::text) THEN revenue.gross_revenue
            ELSE (0)::numeric
        END) AS gross_video_revenue,
    sum(
        CASE
            WHEN ((revenue.source)::text = 'AdThrive Media'::text) THEN revenue.gross_revenue
            ELSE (0)::numeric
        END) AS gross_adthrive_revenue,
    sum(revenue.gross_revenue) AS total_gross_revenue
   FROM revenue
  GROUP BY revenue.date;


--
-- Name: site_analytic_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    users integer
);


--
-- Name: site_analytic; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_analytic AS
 SELECT site_analytic_account.date,
    site_analytic_account.site_id,
    sum(site_analytic_account.pageviews) AS pageviews,
    sum(site_analytic_account.exits) AS exits,
    sum(site_analytic_account.sessions) AS sessions,
    sum(site_analytic_account.bounces) AS bounces,
    avg(site_analytic_account.bounce_rate) AS bounce_rate,
    sum(site_analytic_account.session_duration) AS session_duration,
    sum(site_analytic_account.unique_pageviews) AS unique_pageviews,
    sum(site_analytic_account.time_on_page) AS time_on_page
   FROM public.site_analytic_account
  GROUP BY site_analytic_account.date, site_analytic_account.site_id;


--
-- Name: site_earning_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source (
    date date NOT NULL,
    site_id character varying(255) NOT NULL,
    ad_network_id character varying(255) NOT NULL,
    ad_unit character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean DEFAULT false,
    measurable_impressions integer,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: cmi_revenue_report; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cmi_revenue_report AS
 WITH pageview AS (
         SELECT site_analytic.date,
            round(sum(site_analytic.pageviews)) AS pvs
           FROM (public.site_analytic
             JOIN public.site ON ((((site.id)::text = (site_analytic.site_id)::text) AND ((site.status)::text = 'Active'::text))))
          GROUP BY site_analytic.date
        ), impression AS (
         SELECT site_earning_source.date,
            round((sum(site_earning_source.impressions))::double precision) AS imp
           FROM (public.site_earning_source
             JOIN public.site ON ((((site.id)::text = (site_earning_source.site_id)::text) AND ((site.status)::text = 'Active'::text))))
          WHERE (((site_earning_source.source)::text = 'DFP'::text) AND ((site_earning_source.ad_network_id)::text = ANY (ARRAY[('52e72f29208f222c05b99d99'::character varying)::text, ('5750646c4c854b2213f77f5f'::character varying)::text])))
          GROUP BY site_earning_source.date
        )
 SELECT pageview.date,
    pageview.pvs,
    impression.imp,
    revenue.net_gum_gum_revenue,
    revenue.net_video_revenue,
    revenue.net_adthrive_revenue,
    revenue.total_net_revenue,
    revenue.gross_gum_gum_revenue,
    revenue.gross_video_revenue,
    revenue.gross_adthrive_revenue,
    revenue.total_gross_revenue,
    (((revenue.total_net_revenue)::double precision / NULLIF((pageview.pvs)::double precision, (0)::double precision)) * (1000)::double precision) AS net_rpm,
    (((revenue.total_gross_revenue)::double precision / NULLIF((pageview.pvs)::double precision, (0)::double precision)) * (1000)::double precision) AS gross_rpm,
    (((revenue.total_gross_revenue)::double precision / NULLIF(impression.imp, (0)::double precision)) * (1000)::double precision) AS gross_ecpm,
    (impression.imp / NULLIF((pageview.pvs)::double precision, (0)::double precision)) AS imp_pv
   FROM ((public.cmi_revenue revenue
     JOIN pageview ON ((pageview.date = revenue.date)))
     JOIN impression ON ((impression.date = revenue.date)));


--
-- Name: cms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms (
    id bigint NOT NULL,
    name character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cms_id_seq OWNED BY public.cms.id;


--
-- Name: codeserve_errors_2021_04_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.codeserve_errors_2021_04_12 (
    site_id character varying(255),
    codeserves integer
);


--
-- Name: content_optimization_algorithm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_optimization_algorithm (
    id integer NOT NULL,
    version_name character varying(50) NOT NULL,
    parameters jsonb NOT NULL,
    metrics jsonb NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_by character varying(24),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: content_optimization_algorithm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_optimization_algorithm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_optimization_algorithm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_optimization_algorithm_id_seq OWNED BY public.content_optimization_algorithm.id;


--
-- Name: content_optimization_onboarding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_optimization_onboarding (
    site_id character varying(255) NOT NULL,
    data json
);


--
-- Name: data_source_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_source_sequence
    START WITH 155
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_source_sequence; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_source_sequence OWNED BY public.data_source.id;


--
-- Name: default_ad_layout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.default_ad_layout (
    id integer NOT NULL,
    ad_location_id text NOT NULL,
    ordering smallint NOT NULL,
    sequence integer,
    inactive boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    json jsonb
);


--
-- Name: default_ad_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.default_ad_layout_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: default_ad_layout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.default_ad_layout_id_seq OWNED BY public.default_ad_layout.id;


--
-- Name: default_video_ad_player; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.default_video_ad_player (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    description character varying(1000),
    enabled boolean DEFAULT false NOT NULL,
    type character varying(50) NOT NULL,
    devices text[] NOT NULL,
    properties json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: default_video_ad_player_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.default_video_ad_player_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: default_video_ad_player_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.default_video_ad_player_id_seq OWNED BY public.default_video_ad_player.id;


--
-- Name: device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device (
    id character varying(255) NOT NULL,
    name character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: dropped_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dropped_reason (
    id integer NOT NULL,
    dropped_reason_category_id integer NOT NULL,
    text character varying(255) NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: dropped_reason_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dropped_reason_category (
    id integer NOT NULL,
    text character varying(255) NOT NULL
);


--
-- Name: dropped_reason_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dropped_reason_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dropped_reason_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dropped_reason_category_id_seq OWNED BY public.dropped_reason_category.id;


--
-- Name: dropped_reason_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dropped_reason_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dropped_reason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dropped_reason_id_seq OWNED BY public.dropped_reason.id;


--
-- Name: entity_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_settings (
    id integer NOT NULL,
    entity_type text NOT NULL,
    entity_id text NOT NULL,
    key text NOT NULL,
    value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: entity_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_settings_id_seq OWNED BY public.entity_settings.id;


--
-- Name: feature_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_flags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_admin boolean DEFAULT false NOT NULL,
    is_pubdash boolean DEFAULT false NOT NULL
);


--
-- Name: feature_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feature_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feature_flags_id_seq OWNED BY public.feature_flags.id;


--
-- Name: gam_top_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gam_top_line (
    date date NOT NULL,
    gross_earnings numeric(13,6),
    impressions integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: guided_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guided_action (
    name text NOT NULL,
    priority integer NOT NULL,
    card_content_template text NOT NULL,
    submission_content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    allow_multiple boolean NOT NULL,
    feature_flag character varying(255)
);


--
-- Name: job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job (
    id integer NOT NULL,
    start_date date,
    end_date date,
    name character varying(255),
    status character varying(255) DEFAULT 'started'::character varying,
    started_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_id_seq OWNED BY public.job.id;


--
-- Name: job_issue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_issue (
    id integer NOT NULL,
    job_id integer,
    site_id character varying(255),
    start_date date,
    end_date date,
    type character varying(255),
    message character varying(1000),
    error json,
    resolved boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: job_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_issue_id_seq OWNED BY public.job_issue.id;


--
-- Name: knex_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knex_migrations (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knex_migrations_id_seq OWNED BY public.knex_migrations.id;


--
-- Name: knex_migrations_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knex_migrations_lock (
    is_locked integer
);


--
-- Name: log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log (
    id integer NOT NULL,
    site_id character varying(255),
    type character varying(255),
    message character varying(1000),
    error json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: manual_gamlog_page_path_20210526; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manual_gamlog_page_path_20210526 (
    date date NOT NULL,
    site_id character varying(25) NOT NULL,
    page_path text NOT NULL,
    impressions integer,
    gross_revenue numeric(40,20),
    measurable_impressions integer,
    viewable_impressions integer,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: manual_gamlog_page_path_20210526_json; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manual_gamlog_page_path_20210526_json (
    json jsonb
);


--
-- Name: mcm_child_publisher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcm_child_publisher (
    id integer NOT NULL,
    invite_name text,
    invite_email text,
    company_id text NOT NULL,
    name text,
    email text,
    child_network_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mcm_child_publisher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mcm_child_publisher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mcm_child_publisher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mcm_child_publisher_id_seq OWNED BY public.mcm_child_publisher.id;


--
-- Name: mcm_migration_child_publisher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcm_migration_child_publisher (
    id integer NOT NULL,
    user_id character varying(25),
    status text DEFAULT 'NO_ACTION'::text,
    invite_email character varying(255),
    invite_name text,
    primer_sent_at timestamp without time zone,
    invited_at timestamp without time zone,
    approved_at timestamp without time zone,
    mcm_id text,
    mcm_name text,
    mcm_email text,
    mcm_status text,
    mcm_account_status text,
    mcm_child_network_code text,
    mcm_last_modified_timestamp text,
    staging_batch_num integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    last_error text,
    origin text DEFAULT 'migration'::text NOT NULL
);


--
-- Name: mcm_migration_child_publisher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mcm_migration_child_publisher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mcm_migration_child_publisher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mcm_migration_child_publisher_id_seq OWNED BY public.mcm_migration_child_publisher.id;


--
-- Name: mcm_migration_reminder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcm_migration_reminder (
    id integer NOT NULL,
    mcm_migration_child_publisher_id integer NOT NULL,
    reminder_type text NOT NULL,
    alert_id integer,
    reminder_sent_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: mcm_migration_reminder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mcm_migration_reminder_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mcm_migration_reminder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mcm_migration_reminder_id_seq OWNED BY public.mcm_migration_reminder.id;


--
-- Name: mcm_migration_site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcm_migration_site (
    id integer NOT NULL,
    mcm_migration_child_publisher_id integer,
    site_id character varying(25),
    invite_url text,
    invited_at timestamp without time zone,
    approved_at timestamp without time zone,
    status text DEFAULT 'NO_ACTION'::text,
    mcm_id text,
    mcm_url text,
    mcm_child_network_code text,
    mcm_status text,
    staging_batch_num integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    activated_at timestamp without time zone,
    last_error text,
    origin text DEFAULT 'migration'::text NOT NULL
);


--
-- Name: mcm_migration_site_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mcm_migration_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mcm_migration_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mcm_migration_site_id_seq OWNED BY public.mcm_migration_site.id;


--
-- Name: mcm_migration_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcm_migration_staging (
    id integer NOT NULL,
    user_id character varying(25),
    user_email text,
    invite_name text,
    invite_email text,
    site_id character varying(25),
    site_name text,
    site_url text,
    staging_batch_num integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: mcm_migration_staging_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mcm_migration_staging_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mcm_migration_staging_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mcm_migration_staging_id_seq OWNED BY public.mcm_migration_staging.id;


--
-- Name: mcm_org_migration_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mcm_org_migration_staging (
    mcm_id text,
    mcm_child_network_code text,
    org_id text,
    org_name text,
    site_id text,
    staging_batch_num integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: note_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_attachments (
    note_id integer NOT NULL,
    s3_file_id integer NOT NULL
);


--
-- Name: note_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_status (
    id integer NOT NULL,
    text text NOT NULL
);


--
-- Name: note_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_status_id_seq OWNED BY public.note_status.id;


--
-- Name: note_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_types (
    id integer NOT NULL,
    text character varying(255) NOT NULL
);


--
-- Name: note_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_types_id_seq OWNED BY public.note_types.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    note_type_id integer NOT NULL,
    title text,
    text text,
    is_flagged boolean DEFAULT false NOT NULL,
    created_by text NOT NULL,
    last_updated_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    note_status_id integer DEFAULT 1 NOT NULL,
    entity_type text NOT NULL,
    entity_id text NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    id character varying(255) NOT NULL,
    title character varying(1000),
    type character varying(255),
    body character varying(8000),
    inactive boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: org_demographic_info_migration_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_demographic_info_migration_staging (
    org_id character varying(24),
    user_id text,
    site_id text,
    email text,
    race_ethnicity text[],
    gender text,
    children_birth_years integer[],
    minority_owned boolean,
    lgbtq boolean,
    disability boolean,
    military_service text,
    opt_in_targeted_ad_campaigns boolean,
    staging_batch_num integer NOT NULL
);


--
-- Name: org_owner_migration_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_owner_migration_staging (
    org_id text,
    site_id text,
    user_id text,
    user_email text,
    staging_batch_num integer NOT NULL
);


--
-- Name: organization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization (
    id text DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    is_platinum boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    account_manager_id character varying(255),
    primary_url character varying(255),
    primary_email character varying(255),
    mcm_child_publisher_id integer,
    owner_user_id character varying(255),
    primary_contact_user_id character varying(255)
);


--
-- Name: organization_demographic_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_demographic_info (
    id integer NOT NULL,
    organization_id character varying(24) NOT NULL,
    race_ethnicity text[],
    gender text,
    children_birth_years integer[],
    minority_owned boolean,
    lgbtq boolean,
    disability boolean,
    military_service text,
    opt_in_targeted_ad_campaigns boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_demographic_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_demographic_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_demographic_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_demographic_info_id_seq OWNED BY public.organization_demographic_info.id;


--
-- Name: organization_url_backfill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_url_backfill (
    organization_id text,
    url character varying(255)
);


--
-- Name: organization_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_user (
    organization_id character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission (
    id integer NOT NULL,
    name text NOT NULL,
    deleted_at timestamp without time zone,
    key text NOT NULL,
    description text,
    can_view boolean DEFAULT false NOT NULL,
    can_manage boolean DEFAULT false NOT NULL,
    CONSTRAINT managers_can_always_view CHECK ((NOT (can_manage AND (NOT can_view))))
);


--
-- Name: permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_id_seq OWNED BY public.permission.id;


--
-- Name: pg_stat_activity_dd; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.pg_stat_activity_dd AS
 SELECT pg_stat_activity.datid,
    pg_stat_activity.datname,
    pg_stat_activity.pid,
    pg_stat_activity.usesysid,
    pg_stat_activity.usename,
    pg_stat_activity.application_name,
    pg_stat_activity.client_addr,
    pg_stat_activity.client_hostname,
    pg_stat_activity.client_port,
    pg_stat_activity.backend_start,
    pg_stat_activity.xact_start,
    pg_stat_activity.query_start,
    pg_stat_activity.state_change,
    pg_stat_activity.wait_event_type,
    pg_stat_activity.wait_event,
    pg_stat_activity.state,
    pg_stat_activity.backend_xid,
    pg_stat_activity.backend_xmin,
    pg_stat_activity.query
   FROM public.pg_stat_activity() pg_stat_activity(datid, datname, pid, usesysid, usename, application_name, client_addr, client_hostname, client_port, backend_start, xact_start, query_start, state_change, wait_event_type, wait_event, state, backend_xid, backend_xmin, query, backend_type);


--
-- Name: primis_ad_server_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.primis_ad_server_report (
    date date NOT NULL,
    domain text NOT NULL,
    hb_partner character varying(255) NOT NULL,
    device_type character varying(255) NOT NULL,
    placement_id character varying(255) NOT NULL,
    placement_name text NOT NULL,
    ad_imps bigint NOT NULL,
    ad_clicks bigint NOT NULL,
    ad_revenue double precision NOT NULL
);


--
-- Name: primis_ad_server_revenue_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.primis_ad_server_revenue_adjustment (
    date date NOT NULL,
    appnexus double precision NOT NULL,
    index_exchange double precision NOT NULL,
    pubmatic double precision NOT NULL
);


--
-- Name: primis_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.primis_earning (
    date date NOT NULL,
    site_id character varying(255) NOT NULL,
    sub_id character varying(255) NOT NULL,
    space_name text NOT NULL,
    device_type character varying(255) NOT NULL,
    unique_impressions bigint NOT NULL,
    impressions bigint NOT NULL,
    gross_primis_earnings double precision NOT NULL,
    gross_ad_server_earnings double precision NOT NULL,
    primis_earnings double precision NOT NULL,
    ad_server_earnings double precision NOT NULL,
    primis_impressions bigint NOT NULL,
    ad_server_impressions bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    rev_share integer NOT NULL
);


--
-- Name: primis_media_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.primis_media_report (
    date date NOT NULL,
    sub_id character varying(255) NOT NULL,
    domain text NOT NULL,
    device_type character varying(255) NOT NULL,
    placement_id character varying(255) NOT NULL,
    placement_name text NOT NULL,
    total_impressions bigint NOT NULL,
    unique_impressions bigint NOT NULL,
    primis_impressions bigint NOT NULL,
    ad_server_impressions bigint NOT NULL,
    primis_revenue double precision NOT NULL,
    ad_server_revenue double precision NOT NULL
);


--
-- Name: publisher_application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application (
    id bigint NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    site_id character varying(25),
    site_name character varying(100),
    site_url character varying(255),
    pageviews integer,
    ads_running boolean DEFAULT false,
    referral_source character varying(255),
    google_analytics_email character varying(255),
    google_analytics_access_token character varying(255),
    google_analytics_refresh_token character varying(255),
    status character varying(25),
    accepted_date date,
    reject_reason character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ad_strategy character varying(255),
    legacy_id character varying,
    referral_source_other text,
    send_auto_rejection_email boolean DEFAULT false NOT NULL,
    reminder_email_sent_at timestamp with time zone,
    public_id character varying(36) DEFAULT public.uuid_generate_v4() NOT NULL,
    application_type character varying(25) DEFAULT 'Applied'::character varying NOT NULL,
    is_existing_user boolean DEFAULT false NOT NULL,
    is_pub_dev_site boolean DEFAULT false NOT NULL,
    submitted_at timestamp with time zone,
    organization_id text,
    suggested_outcome character varying(255)
);


--
-- Name: publisher_application_ad_network; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_ad_network (
    publisher_application_id bigint,
    data_source_id character varying(255),
    name character varying(255),
    status character varying(25),
    in_contract boolean DEFAULT false,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publisher_application_analytics_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_analytics_account (
    publisher_application_id bigint NOT NULL,
    account_id character varying(255) NOT NULL,
    account_name character varying(255),
    web_property_id character varying(255) NOT NULL,
    web_property_name character varying(255),
    profile_id character varying(255) NOT NULL,
    profile_name character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ga_type character varying(3) DEFAULT 'UA'::character varying
);


--
-- Name: publisher_application_analytics_profile_by_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_analytics_profile_by_country (
    date date NOT NULL,
    publisher_application_id bigint NOT NULL,
    analytics_profile_id character varying(255) NOT NULL,
    country character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publisher_application_analytics_profile_by_date; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_analytics_profile_by_date (
    date date NOT NULL,
    publisher_application_id bigint NOT NULL,
    analytics_profile_id character varying(255) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publisher_application_analytics_profile_by_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_analytics_profile_by_device (
    date date NOT NULL,
    publisher_application_id bigint NOT NULL,
    analytics_profile_id character varying(255) NOT NULL,
    device_category character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publisher_application_analytics_profile_by_page_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_analytics_profile_by_page_title (
    date date NOT NULL,
    publisher_application_id bigint NOT NULL,
    analytics_profile_id character varying(255) NOT NULL,
    page_title character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    page_path text DEFAULT 'none'::text NOT NULL
);


--
-- Name: publisher_application_analytics_profile_by_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_analytics_profile_by_source (
    date date NOT NULL,
    publisher_application_id bigint NOT NULL,
    analytics_profile_id character varying(255) NOT NULL,
    source character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publisher_application_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publisher_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publisher_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publisher_application_id_seq OWNED BY public.publisher_application.id;


--
-- Name: publisher_application_vertical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_application_vertical (
    publisher_application_id bigint NOT NULL,
    vertical_id character varying(255) NOT NULL,
    "primary" boolean DEFAULT false,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publisher_dashboard_today_override; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publisher_dashboard_today_override (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    created_by character varying(50) NOT NULL,
    activated_at timestamp with time zone NOT NULL,
    deactivated_at timestamp with time zone,
    message text
);


--
-- Name: publisher_dashboard_today_override_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publisher_dashboard_today_override_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publisher_dashboard_today_override_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publisher_dashboard_today_override_id_seq OWNED BY public.publisher_dashboard_today_override.id;


--
-- Name: request_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.request_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_log (
    id integer DEFAULT nextval('public.request_log_id_seq'::regclass) NOT NULL,
    date timestamp with time zone,
    method character varying(255),
    url character varying(2000),
    status_code integer,
    status_message character varying(255),
    user_agent character varying(2000),
    ip_address character varying(255),
    site_id character varying(255),
    user_id character varying(255),
    error json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: request_log_old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_log_old (
    id integer DEFAULT nextval('public.request_log_id_seq'::regclass) NOT NULL,
    date timestamp with time zone,
    method character varying(255),
    url character varying(2000),
    status_code character varying(255),
    status_message character varying(255),
    user_agent character varying(2000),
    ip_address character varying(255),
    site_id character varying(255),
    user_id character varying(255),
    error json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: revenue_adjustment_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.revenue_adjustment_history (
    id integer NOT NULL,
    adjustment_date timestamp without time zone DEFAULT now() NOT NULL,
    description text,
    csv_s3_id character varying(24),
    updated_by character varying(24)
);


--
-- Name: revenue_adjustment_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.revenue_adjustment_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: revenue_adjustment_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.revenue_adjustment_history_id_seq OWNED BY public.revenue_adjustment_history.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    id integer NOT NULL,
    user_type text NOT NULL,
    name text NOT NULL,
    description text,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    relation_type text
);


--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: role_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permission (
    user_role_id integer,
    permission_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    role_id integer NOT NULL
);


--
-- Name: s3_bucket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s3_bucket (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: s3_bucket_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.s3_bucket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: s3_bucket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.s3_bucket_id_seq OWNED BY public.s3_bucket.id;


--
-- Name: s3_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.s3_file (
    id bigint NOT NULL,
    bucket_id integer NOT NULL,
    key character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: s3_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.s3_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: s3_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.s3_file_id_seq OWNED BY public.s3_file.id;


--
-- Name: site_ad_density; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_density (
    site_id character varying(24) NOT NULL,
    device public.site_ad_density_device NOT NULL,
    density numeric(2,2) NOT NULL,
    view_port_override boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_ad_density_enabled; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_density_enabled (
    site_id character varying(24) NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL
);


--
-- Name: site_ad_density_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_density_meta (
    site_id character varying(24) NOT NULL,
    updated_at timestamp with time zone,
    published_at timestamp with time zone
);


--
-- Name: site_ad_density_override; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_density_override (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    device public.site_ad_density_device NOT NULL,
    density numeric(2,2) NOT NULL,
    view_port_override boolean NOT NULL,
    page_selector text NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_ad_density_override_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_ad_density_override_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_ad_density_override_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_ad_density_override_id_seq OWNED BY public.site_ad_density_override.id;


--
-- Name: site_ad_layout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_layout (
    id character varying(255) NOT NULL,
    site_id character varying(255),
    ad_location_id character varying(255),
    sequence integer,
    sticky boolean,
    sticky_overlap_selector character varying(255),
    autosize boolean,
    inactive boolean,
    dynamic boolean,
    page_selector character varying(2000),
    element_selector character varying(2000),
    "position" character varying(255),
    min numeric(12,2),
    max numeric(12,2),
    spacing numeric(12,2),
    skip numeric(12,2),
    every numeric(12,2),
    class_names character varying(255),
    ad_sizes jsonb,
    targeting jsonb,
    devices jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    json jsonb,
    ordering smallint,
    deleted_at timestamp with time zone
);


--
-- Name: site_ad_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_ad_layout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_ad_layout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_ad_layout_id_seq OWNED BY public.site_ad_layout.id;


--
-- Name: site_ad_layout_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_layout_meta (
    site_id character varying(255) NOT NULL,
    updated_at timestamp with time zone,
    published_at timestamp with time zone
);


--
-- Name: site_ad_network_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_network_earning (
    date date NOT NULL,
    site_id character varying(255) NOT NULL,
    ad_network_id character varying(255),
    ad_unit character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    impressions integer,
    earnings numeric(12,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_ad_sense_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_sense_earning (
    date date NOT NULL,
    site_id character varying(255) NOT NULL,
    ad_unit character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    ad_requests integer,
    clicks integer,
    earnings numeric(12,6),
    matched_ad_requests integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_ad_sense_earning_domain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ad_sense_earning_domain (
    date date NOT NULL,
    site_id character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    domain character varying(255) NOT NULL,
    ad_requests integer,
    clicks integer,
    earnings numeric(12,2),
    matched_ad_requests integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_add_user_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_add_user_codes (
    site_id character varying(255) NOT NULL,
    add_user_code character varying(255) NOT NULL
);


--
-- Name: site_alert; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_alert (
    id integer NOT NULL,
    site_id character varying(255) NOT NULL,
    alert_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: site_alert_closed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_alert_closed (
    id integer NOT NULL,
    site_id character varying(255) NOT NULL,
    alert_id integer NOT NULL,
    closed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_alert_closed_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_alert_closed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_alert_closed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_alert_closed_id_seq OWNED BY public.site_alert_closed.id;


--
-- Name: site_alert_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_alert_id_seq OWNED BY public.site_alert.id;


--
-- Name: site_analytic_account_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_country (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    country character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_country_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_country_temp (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    country character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_device_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_device_category (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    device_category character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_device_category_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_device_category_temp (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    device_category character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_dimension; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_dimension (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(5000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    users integer
);


--
-- Name: site_analytic_account_page_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_page_title (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    page_title character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    page_path text DEFAULT 'none'::text NOT NULL,
    clean_page_path text
);


--
-- Name: site_analytic_account_page_title_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_page_title_temp (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    page_title character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    page_path text DEFAULT 'none'::text NOT NULL,
    clean_page_path text
);


--
-- Name: site_analytic_account_social_network; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_social_network (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    social_network character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_social_network_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_social_network_temp (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    social_network character varying(50) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_source (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    source character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_source_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_source_temp (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    source character varying(1000) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    users integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_analytic_account_speed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_speed (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    page_load_time numeric(12,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    page_load_sample numeric(12,2),
    avg_domain_lookup_time numeric(12,2),
    avg_page_download_time numeric(12,2),
    avg_redirection_time numeric(12,2),
    avg_server_connection_time numeric(12,2),
    avg_server_response_time numeric(12,2),
    avg_dom_interactive_time numeric(12,2),
    avg_dom_content_loaded_time numeric(12,2),
    avg_page_load_time numeric(12,2)
);


--
-- Name: site_analytic_account_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_analytic_account_temp (
    site_id character varying(255) NOT NULL,
    date date NOT NULL,
    account character varying(255) NOT NULL,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    bounces numeric(12,2),
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unique_pageviews numeric(12,2),
    time_on_page numeric(12,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    users integer
);


--
-- Name: site_analytic_by_device; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_analytic_by_device AS
 SELECT site_analytic_account_device_category.date,
    site_analytic_account_device_category.site_id,
    site_analytic_account_device_category.device_category AS device,
    sum(site_analytic_account_device_category.pageviews) AS pageviews,
    sum(site_analytic_account_device_category.exits) AS exits,
    sum(site_analytic_account_device_category.sessions) AS sessions,
    sum(site_analytic_account_device_category.bounces) AS bounces,
    avg(site_analytic_account_device_category.bounce_rate) AS bounce_rate,
    sum(site_analytic_account_device_category.session_duration) AS session_duration,
    sum(site_analytic_account_device_category.unique_pageviews) AS unique_pageviews,
    sum(site_analytic_account_device_category.time_on_page) AS time_on_page,
    max(site_analytic_account_device_category.updated_at) AS updated_at,
    min(site_analytic_account_device_category.created_at) AS created_at
   FROM public.site_analytic_account_device_category
  GROUP BY site_analytic_account_device_category.date, site_analytic_account_device_category.site_id, site_analytic_account_device_category.device_category;


--
-- Name: site_monthly_analytic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_monthly_analytic (
    date date,
    site_id character varying(255) NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    pageviews numeric(12,2),
    sessions numeric(12,2),
    users numeric(12,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_analytic_monthly; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_analytic_monthly AS
 SELECT site_monthly_analytic.site_id,
    site_monthly_analytic.year,
    site_monthly_analytic.month,
    site_monthly_analytic.date,
    site_monthly_analytic.pageviews,
    site_monthly_analytic.sessions,
    site_monthly_analytic.updated_at,
    site_monthly_analytic.created_at
   FROM public.site_monthly_analytic
  WHERE (site_monthly_analytic.date < '2017-05-01'::date)
UNION ALL
 SELECT site_analytic_account.site_id,
    date_part('year'::text, site_analytic_account.date) AS year,
    (date_part('month'::text, site_analytic_account.date) - (1)::double precision) AS month,
    max(site_analytic_account.date) AS date,
    sum(site_analytic_account.pageviews) AS pageviews,
    sum(site_analytic_account.sessions) AS sessions,
    max(site_analytic_account.updated_at) AS updated_at,
    min(site_analytic_account.created_at) AS created_at
   FROM public.site_analytic_account
  GROUP BY site_analytic_account.site_id, (date_part('year'::text, site_analytic_account.date)), (date_part('month'::text, site_analytic_account.date) - (1)::double precision);


--
-- Name: site_analytic_speed; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_analytic_speed AS
 SELECT site_analytic_account_speed.date,
    site_analytic_account_speed.site_id,
    avg(site_analytic_account_speed.avg_page_load_time) AS avg_page_load_time,
    avg(site_analytic_account_speed.avg_domain_lookup_time) AS avg_domain_lookup_time,
    avg(site_analytic_account_speed.avg_page_download_time) AS avg_page_download_time,
    avg(site_analytic_account_speed.avg_redirection_time) AS avg_redirection_time,
    avg(site_analytic_account_speed.avg_server_connection_time) AS avg_server_connection_time,
    avg(site_analytic_account_speed.avg_server_response_time) AS avg_server_response_time,
    avg(site_analytic_account_speed.avg_dom_interactive_time) AS avg_dom_interactive_time,
    avg(site_analytic_account_speed.avg_dom_content_loaded_time) AS avg_dom_content_loaded_time,
    max(site_analytic_account_speed.updated_at) AS updated_at,
    min(site_analytic_account_speed.created_at) AS created_at
   FROM public.site_analytic_account_speed
  GROUP BY site_analytic_account_speed.date, site_analytic_account_speed.site_id;


--
-- Name: site_authorization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_authorization (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    site_id character varying(255),
    email character varying(255),
    access_token character varying(255),
    refresh_token character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_cms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_cms (
    site_id character varying(25),
    cms_id integer,
    login_url character varying(255),
    "user" character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_company_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_company_temp (
    site_id character varying(255) NOT NULL,
    site_name character varying(100) NOT NULL,
    site_company_name text,
    proposed_organization_name text
);


--
-- Name: site_competitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_competitors (
    site_id character varying(24) NOT NULL,
    competitor_domains jsonb,
    competitor_domains_current jsonb,
    use_list boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: site_config_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_config_activity (
    site_id character varying(24) NOT NULL,
    config_name character varying(50) NOT NULL,
    updated_at timestamp with time zone,
    published_at timestamp with time zone
);


--
-- Name: site_content_brief; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_content_brief (
    id character varying(24) NOT NULL,
    site_id character varying(24) NOT NULL,
    type text NOT NULL,
    status text NOT NULL,
    url text,
    keyword text NOT NULL,
    publish_date date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    was_recommended boolean DEFAULT false NOT NULL,
    completed_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language text
);


--
-- Name: site_data_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_data_source (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    site_id character varying(255),
    data_source_id character varying(255),
    site_authorization_id character varying(255),
    account character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    ad_sense_domains character varying(8000),
    inactive boolean DEFAULT false NOT NULL,
    ga4_property_id character varying(25)
);


--
-- Name: site_demographic_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_demographic_info (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    race_ethnicity text[],
    gender text,
    children text,
    children_birth_years integer[],
    minority_owned text,
    sexual_orientation text,
    opt_in_targeted_ad_campaigns boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_demographic_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_demographic_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_demographic_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_demographic_info_id_seq OWNED BY public.site_demographic_info.id;


--
-- Name: site_earning; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning AS
 SELECT site_earning_source.date,
    site_earning_source.site_id,
    sum(site_earning_source.clicks) AS clicks,
    sum(site_earning_source.impressions) AS impressions,
    sum(site_earning_source.measurable_impressions) AS measurable_impressions,
    sum(site_earning_source.viewable_impressions) AS viewable_impressions,
    sum(site_earning_source.gross_earnings) AS gross_earnings,
    sum(site_earning_source.earnings) AS earnings,
    max(site_earning_source.updated_at) AS updated_at,
    min(site_earning_source.created_at) AS created_at
   FROM public.site_earning_source
  GROUP BY site_earning_source.date, site_earning_source.site_id;


--
-- Name: site_earning_analytic; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_analytic AS
 SELECT site_earning.date,
    site_earning.site_id,
    site_earning.clicks,
    site_earning.impressions,
    site_earning.measurable_impressions,
    site_earning.viewable_impressions,
    site_earning.gross_earnings,
    site_earning.earnings,
    site_analytic.pageviews,
    site_analytic.exits,
    site_analytic.sessions,
    site_analytic.bounces,
    site_analytic.bounce_rate,
    site_analytic.session_duration,
    site_analytic.unique_pageviews,
    site_analytic.time_on_page,
    ((site_earning.earnings / NULLIF(site_analytic.pageviews, (0)::numeric)) * (1000)::numeric) AS rpm,
    ((site_earning.earnings / NULLIF(site_analytic.sessions, (0)::numeric)) * (1000)::numeric) AS rps
   FROM (public.site_earning
     JOIN public.site_analytic ON ((((site_analytic.site_id)::text = (site_earning.site_id)::text) AND (site_analytic.date = site_earning.date))));


--
-- Name: site_earning_by_device; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_by_device AS
 SELECT site_earning_source.date,
    site_earning_source.site_id,
    site_earning_source.device,
    sum(site_earning_source.clicks) AS clicks,
    sum(site_earning_source.impressions) AS impressions,
    sum(site_earning_source.measurable_impressions) AS measurable_impressions,
    sum(site_earning_source.viewable_impressions) AS viewable_impressions,
    sum(site_earning_source.gross_earnings) AS gross_earnings,
    sum(site_earning_source.earnings) AS earnings,
    max(site_earning_source.updated_at) AS updated_at,
    min(site_earning_source.created_at) AS created_at
   FROM public.site_earning_source
  GROUP BY site_earning_source.date, site_earning_source.site_id, site_earning_source.device;


--
-- Name: site_earning_analytic_by_device; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_analytic_by_device AS
 SELECT site_earning_by_device.date,
    site_earning_by_device.site_id,
    site_earning_by_device.device,
    site_earning_by_device.clicks,
    site_earning_by_device.impressions,
    site_earning_by_device.measurable_impressions,
    site_earning_by_device.viewable_impressions,
    site_earning_by_device.gross_earnings,
    site_earning_by_device.earnings,
    site_analytic_by_device.pageviews,
    site_analytic_by_device.exits,
    site_analytic_by_device.sessions,
    site_analytic_by_device.bounces,
    site_analytic_by_device.bounce_rate,
    site_analytic_by_device.session_duration,
    site_analytic_by_device.unique_pageviews,
    site_analytic_by_device.time_on_page,
    ((site_earning_by_device.earnings / NULLIF(site_analytic_by_device.pageviews, (0)::numeric)) * (1000)::numeric) AS rpm,
    ((site_earning_by_device.earnings / NULLIF(site_analytic_by_device.sessions, (0)::numeric)) * (1000)::numeric) AS rps
   FROM (public.site_earning_by_device
     JOIN public.site_analytic_by_device ON ((((site_analytic_by_device.site_id)::text = (site_earning_by_device.site_id)::text) AND (site_analytic_by_device.date = site_earning_by_device.date) AND ((site_analytic_by_device.device)::text = (site_earning_by_device.device)::text))));


--
-- Name: site_monthly_earning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_monthly_earning (
    date date,
    year integer NOT NULL,
    month integer NOT NULL,
    site_id character varying(255) NOT NULL,
    ad_network_id character varying(255) NOT NULL,
    earnings numeric(12,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_earning_monthly_by_ad_network; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_monthly_by_ad_network AS
 SELECT site_monthly_earning.site_id,
    site_monthly_earning.ad_network_id,
    site_monthly_earning.year,
    site_monthly_earning.month,
    site_monthly_earning.date,
    site_monthly_earning.earnings,
    site_monthly_earning.updated_at,
    site_monthly_earning.created_at
   FROM public.site_monthly_earning
  WHERE (site_monthly_earning.date < '2017-05-01'::date)
UNION ALL
 SELECT site_monthly_earning.site_id,
    site_monthly_earning.ad_network_id,
    site_monthly_earning.year,
    site_monthly_earning.month,
    site_monthly_earning.date,
    site_monthly_earning.earnings,
    site_monthly_earning.updated_at,
    site_monthly_earning.created_at
   FROM public.site_monthly_earning
  WHERE ((site_monthly_earning.date >= '2017-05-01'::date) AND ((site_monthly_earning.ad_network_id)::text <> ALL (ARRAY[('52e72f29208f222c05b99d99'::character varying)::text, ('544565368f7e976723da6efc'::character varying)::text, ('5750646c4c854b2213f77f5f'::character varying)::text, ('52e72f42208f222c05b99d9b'::character varying)::text])))
UNION ALL
 SELECT site_earning_source.site_id,
    site_earning_source.ad_network_id,
    date_part('year'::text, site_earning_source.date) AS year,
    (date_part('month'::text, site_earning_source.date) - (1)::double precision) AS month,
    max(site_earning_source.date) AS date,
    sum(site_earning_source.earnings) AS earnings,
    max(site_earning_source.updated_at) AS updated_at,
    min(site_earning_source.created_at) AS created_at
   FROM public.site_earning_source
  WHERE (site_earning_source.date >= '2017-05-01'::date)
  GROUP BY site_earning_source.site_id, site_earning_source.ad_network_id, (date_part('year'::text, site_earning_source.date)), (date_part('month'::text, site_earning_source.date) - (1)::double precision);


--
-- Name: site_earning_monthly; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_monthly AS
 SELECT site_earning_monthly_by_ad_network.site_id,
    site_earning_monthly_by_ad_network.year,
    site_earning_monthly_by_ad_network.month,
    max(site_earning_monthly_by_ad_network.date) AS date,
    sum(site_earning_monthly_by_ad_network.earnings) AS earnings,
    max(site_earning_monthly_by_ad_network.updated_at) AS updated_at,
    min(site_earning_monthly_by_ad_network.created_at) AS created_at
   FROM public.site_earning_monthly_by_ad_network
  GROUP BY site_earning_monthly_by_ad_network.site_id, site_earning_monthly_by_ad_network.year, site_earning_monthly_by_ad_network.month;


--
-- Name: site_earning_analytic_monthly; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_analytic_monthly AS
 SELECT site_earning_monthly.site_id,
    site_earning_monthly.year,
    site_earning_monthly.month,
    site_earning_monthly.date,
    site_earning_monthly.earnings,
    site_analytic_monthly.pageviews,
    site_analytic_monthly.sessions,
    ((site_earning_monthly.earnings / NULLIF(site_analytic_monthly.pageviews, (0)::numeric)) * (1000)::numeric) AS rpm,
    ((site_earning_monthly.earnings / NULLIF(site_analytic_monthly.sessions, (0)::numeric)) * (1000)::numeric) AS rps
   FROM (public.site_earning_monthly
     JOIN public.site_analytic_monthly ON ((((site_analytic_monthly.site_id)::text = (site_earning_monthly.site_id)::text) AND (site_analytic_monthly.year = site_earning_monthly.year) AND (site_analytic_monthly.month = site_earning_monthly.month))));


--
-- Name: site_earning_analytics_by_page_path; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_analytics_by_page_path (
    date date NOT NULL,
    site_id character varying(25) NOT NULL,
    page_path text NOT NULL,
    gross_revenue numeric(40,20),
    impressions integer,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    unique_pageviews numeric(12,2),
    users integer,
    has_gamlog_data boolean NOT NULL,
    has_ga_data boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    measurable_impressions integer,
    viewable_impressions integer,
    time_on_page numeric(12,2),
    bounces integer,
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: site_earning_analytics_by_page_path_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_analytics_by_page_path_temp (
    date date,
    site_id character varying(25),
    page_path text,
    gross_revenue numeric(40,20),
    impressions integer,
    pageviews numeric(12,2),
    exits numeric(12,2),
    sessions numeric(12,2),
    unique_pageviews numeric(12,2),
    users integer,
    has_gamlog_data boolean,
    has_ga_data boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    measurable_impressions integer,
    viewable_impressions integer,
    time_on_page numeric(12,2),
    bounces integer,
    bounce_rate numeric(12,2),
    session_duration numeric(12,2),
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: site_earning_by_ad_network; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_by_ad_network AS
 SELECT site_earning_source.date,
    site_earning_source.site_id,
    site_earning_source.ad_network_id,
    sum(site_earning_source.clicks) AS clicks,
    sum(site_earning_source.impressions) AS impressions,
    sum(site_earning_source.measurable_impressions) AS measurable_impressions,
    sum(site_earning_source.viewable_impressions) AS viewable_impressions,
    sum(site_earning_source.gross_earnings) AS gross_earnings,
    sum(site_earning_source.earnings) AS earnings,
    max(site_earning_source.updated_at) AS updated_at,
    min(site_earning_source.created_at) AS created_at
   FROM public.site_earning_source
  GROUP BY site_earning_source.date, site_earning_source.site_id, site_earning_source.ad_network_id;


--
-- Name: site_earning_by_ad_network_device; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_by_ad_network_device AS
 SELECT site_earning_source.date,
    site_earning_source.site_id,
    site_earning_source.ad_network_id,
    site_earning_source.device,
    sum(site_earning_source.clicks) AS clicks,
    sum(site_earning_source.impressions) AS impressions,
    sum(site_earning_source.measurable_impressions) AS measurable_impressions,
    sum(site_earning_source.viewable_impressions) AS viewable_impressions,
    sum(site_earning_source.gross_earnings) AS gross_earnings,
    sum(site_earning_source.earnings) AS earnings,
    max(site_earning_source.updated_at) AS updated_at,
    min(site_earning_source.created_at) AS created_at
   FROM public.site_earning_source
  GROUP BY site_earning_source.date, site_earning_source.site_id, site_earning_source.ad_network_id, site_earning_source.device;


--
-- Name: site_earning_by_ad_network_device_ad_unit; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earning_by_ad_network_device_ad_unit AS
 SELECT site_earning_source.date,
    site_earning_source.site_id,
    site_earning_source.ad_network_id,
    site_earning_source.device,
    site_earning_source.ad_unit,
    sum(site_earning_source.clicks) AS clicks,
    sum(site_earning_source.impressions) AS impressions,
    sum(site_earning_source.measurable_impressions) AS measurable_impressions,
    sum(site_earning_source.viewable_impressions) AS viewable_impressions,
    sum(site_earning_source.gross_earnings) AS gross_earnings,
    sum(site_earning_source.earnings) AS earnings,
    max(site_earning_source.updated_at) AS updated_at,
    max(site_earning_source.created_at) AS created_at
   FROM public.site_earning_source
  GROUP BY site_earning_source.date, site_earning_source.site_id, site_earning_source.ad_network_id, site_earning_source.device, site_earning_source.ad_unit;


--
-- Name: site_earning_source_2020_04_05; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_2020_04_05 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean,
    measurable_impressions integer,
    note character varying(255)
);


--
-- Name: site_earning_source_2020_04_17; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_2020_04_17 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean,
    measurable_impressions integer,
    note character varying(255)
);


--
-- Name: site_earning_source_2020_05_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_2020_05_23 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean,
    measurable_impressions integer,
    note character varying(255)
);


--
-- Name: site_earning_source_2020_06_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_2020_06_01 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean,
    measurable_impressions integer,
    note character varying(255)
);


--
-- Name: site_earning_source_2020_08_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_2020_08_02 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean,
    measurable_impressions integer,
    note character varying(255),
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: site_earning_source_2020_08_29; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_2020_08_29 (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean,
    measurable_impressions integer,
    note character varying(255),
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: site_earning_source_manual; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_manual (
    date date,
    site_id character varying(255),
    ad_network_id character varying(255),
    ad_unit character varying(255),
    device character varying(255),
    source character varying(255),
    impressions integer,
    viewable_impressions integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6)
);


--
-- Name: site_earning_source_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_earning_source_update (
    date date NOT NULL,
    site_id character(24),
    ad_network_id character(24),
    ad_unit character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    impressions integer,
    clicks integer,
    gross_earnings numeric(12,6),
    earnings numeric(12,6),
    measurable_impressions integer,
    viewable_impressions integer
);


--
-- Name: site_earnings_analytics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_earnings_analytics AS
 SELECT all_data.site_id,
    all_data.start_date,
    all_data.end_date,
    sum(all_data.earnings) AS total_earnings,
    sum(all_data.pageviews) AS total_pageviews,
    sum(all_data.sessions) AS total_sessions,
    sum(all_data.time_on_page) AS total_time_on_page,
    sum(all_data.exits) AS total_exits,
    sum((all_data.earnings * (all_data.include_in_calculation)::numeric)) AS rpm_rps_earnings,
    sum((all_data.pageviews * (all_data.include_in_calculation)::numeric)) AS rpm_pageviews,
    sum((all_data.sessions * (all_data.include_in_calculation)::numeric)) AS rps_sessions
   FROM ( SELECT earnings.site_id,
            earnings.date AS start_date,
            earnings.date AS end_date,
            earnings.earnings,
            COALESCE(analytics.pageviews, (0)::numeric) AS pageviews,
            COALESCE(analytics.sessions, (0)::numeric) AS sessions,
            COALESCE(analytics.time_on_page, (0)::numeric) AS time_on_page,
            COALESCE(analytics.exits, (0)::numeric) AS exits,
                CASE
                    WHEN (earnings.earnings > (0)::numeric) THEN 1
                    ELSE 0
                END AS include_in_calculation
           FROM (public.site_earning earnings
             LEFT JOIN public.site_analytic analytics ON (((analytics.date = earnings.date) AND ((analytics.site_id)::text = (earnings.site_id)::text))))
        UNION ALL
         SELECT site_monthly_earning.site_id,
            date_trunc('month'::text, (site_monthly_earning.date)::timestamp with time zone) AS start_date,
            (date_trunc('month'::text, (site_monthly_earning.date)::timestamp with time zone) + '1 mon -1 days'::interval) AS end_date,
            site_monthly_earning.earnings,
            0 AS pageviews,
            0 AS sessions,
            0 AS time_on_page,
            0 AS exits,
            1 AS include_in_calculation
           FROM public.site_monthly_earning
        UNION ALL
         SELECT site_monthly_analytic.site_id,
            date_trunc('month'::text, (site_monthly_analytic.date)::timestamp with time zone) AS start_date,
            (date_trunc('month'::text, (site_monthly_analytic.date)::timestamp with time zone) + '1 mon -1 days'::interval) AS end_date,
            0 AS earnings,
            site_monthly_analytic.pageviews,
            site_monthly_analytic.sessions,
            0 AS time_on_page,
            0 AS exits,
            1 AS include_in_calculation
           FROM public.site_monthly_analytic) all_data
  GROUP BY all_data.site_id, all_data.start_date, all_data.end_date;


--
-- Name: site_experiment_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_experiment_data (
    variant character varying NOT NULL,
    experiment_id character varying NOT NULL,
    site_id character varying(255) NOT NULL,
    device character varying(50) NOT NULL,
    gross_earnings numeric(40,20),
    sessions numeric(12,2),
    pageviews numeric(12,2),
    impressions numeric(12,2),
    session_duration numeric(12,2),
    bounces numeric(12,2),
    time_on_page numeric(12,2),
    date date NOT NULL,
    sessions_gam numeric(12,2),
    pageviews_gam numeric(12,2)
);


--
-- Name: site_gsc_auth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_gsc_auth (
    id integer NOT NULL,
    site_id text NOT NULL,
    url text,
    refresh_token text,
    access_token text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    authed_at timestamp with time zone
);


--
-- Name: site_gsc_auth_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_gsc_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_gsc_auth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_gsc_auth_id_seq OWNED BY public.site_gsc_auth.id;


--
-- Name: site_guided_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_guided_action (
    id integer NOT NULL,
    guided_action_name text,
    site_id character varying(24),
    status text,
    card_content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    snoozed_until timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    context jsonb NOT NULL
);


--
-- Name: site_guided_action_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_guided_action_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_guided_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_guided_action_id_seq OWNED BY public.site_guided_action.id;


--
-- Name: site_ias_brand_safety_by_url; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_ias_brand_safety_by_url (
    site_id character varying(24),
    page_path text,
    date date,
    alc character varying(16),
    alc_prev character varying(16),
    adt character varying(16),
    adt_prev character varying(16),
    dlm character varying(16),
    dlm_prev character varying(16),
    drg character varying(16),
    drg_prev character varying(16),
    hat character varying(16),
    hat_prev character varying(16),
    off character varying(16),
    off_prev character varying(16),
    sam character varying(16),
    sam_prev character varying(16),
    vio character varying(16),
    vio_prev character varying(16),
    nr character varying(16),
    nr_prev character varying(16),
    pageviews bigint,
    pageviews_prev bigint,
    impressions bigint,
    impressions_prev bigint,
    measurable_impressions bigint,
    measurable_impressions_prev bigint,
    viewable_impressions bigint,
    viewable_impressions_prev bigint,
    gross_revenue numeric,
    gross_revenue_prev numeric,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: site_jw_analytic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_jw_analytic (
    date date NOT NULL,
    site_id character varying(25) NOT NULL,
    device_type character varying(10) NOT NULL,
    media_id character varying(10) NOT NULL,
    player_id character varying(10) NOT NULL,
    embeds integer,
    plays integer,
    completes integer,
    "1st_quartile" integer,
    "2nd_quartile" integer,
    "3rd_quartile" integer,
    ad_impressions integer,
    ad_clicks integer,
    ad_skips integer,
    ad_completes integer,
    viewers integer,
    watched_duration integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_jw_player; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_jw_player (
    id text NOT NULL,
    site_id character varying(24) NOT NULL,
    name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_jw_video; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_jw_video (
    id text NOT NULL,
    site_id character varying(24) NOT NULL,
    status text,
    title text,
    description text,
    tags text,
    duration double precision,
    size bigint,
    link text,
    publish_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_excluded_from_sitemap boolean DEFAULT true NOT NULL
);


--
-- Name: site_keyword_recommendation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_keyword_recommendation (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    keyword text NOT NULL,
    type text NOT NULL,
    status text NOT NULL,
    post_url text,
    queue_pos smallint NOT NULL,
    score numeric NOT NULL,
    gsc_pos numeric,
    avg_search_volume numeric NOT NULL,
    upcoming_search_volume numeric NOT NULL,
    post_last_modified_date date,
    post_rpm numeric,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    page_impressions integer,
    page_clicks integer,
    page_position double precision,
    expected_ctr double precision,
    potential_ctr double precision,
    avg_site_rpm double precision,
    min_target_vol double precision,
    max_target_vol double precision,
    winnability_score numeric,
    min_domain_authority integer,
    site_domain_authority integer,
    num_winnable_spots integer,
    strength_areas text[]
);


--
-- Name: site_keyword_recommendation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_keyword_recommendation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_keyword_recommendation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_keyword_recommendation_id_seq OWNED BY public.site_keyword_recommendation.id;


--
-- Name: site_monthly_metric; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_monthly_metric (
    id character varying(255),
    date date,
    site_id character varying(255) NOT NULL,
    data_source_id character varying(255) NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    manual boolean NOT NULL,
    mtd numeric(12,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_offboarding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_offboarding (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    dropped_reason_category text,
    dropped_reason text,
    is_satisfied boolean,
    is_multi_site boolean,
    was_served_thirty_day_notice boolean,
    was_transfer_of_ownership boolean,
    notes text,
    zendesk_link text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: site_offboarding_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_offboarding_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_offboarding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_offboarding_id_seq OWNED BY public.site_offboarding.id;


--
-- Name: site_onboarding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_onboarding (
    site_id character varying(25) NOT NULL,
    wizard1_access boolean DEFAULT false NOT NULL,
    wizard2_access boolean DEFAULT false NOT NULL,
    wizard1_second_analysis boolean DEFAULT false NOT NULL,
    wizard1_completed_at timestamp with time zone,
    wizard2_completed_at timestamp with time zone,
    wizard1_second_analysis_completed_at timestamp with time zone,
    privacy_policy_url character varying(255),
    gam_authorization_url character varying(255),
    gam_authorization_status character varying(50),
    tal_status character varying(50),
    contract_end_date date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    onboarding_date date,
    analytics_email character varying(255),
    ga_complete boolean,
    incoming_notice_date date,
    overrides text[],
    analysis_1_access boolean DEFAULT false NOT NULL,
    analysis_2_access boolean DEFAULT false NOT NULL,
    analysis_1_completed_at timestamp with time zone,
    analysis_2_completed_at timestamp with time zone
);


--
-- Name: site_onboarding_ad_goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_onboarding_ad_goals (
    site_id character varying(24) NOT NULL,
    ad_amount character varying(255),
    goal_importance_ranking character varying(255) NOT NULL,
    create_videos boolean DEFAULT false NOT NULL,
    monetizing_provider character varying(255),
    video_site_map text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_onboarding_ad_layout_ranking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_onboarding_ad_layout_ranking (
    site_id character varying(24) NOT NULL,
    value text NOT NULL,
    rank smallint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_onboarding_screenshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_onboarding_screenshots (
    site_id character varying(25) NOT NULL,
    s3_file_id integer NOT NULL
);


--
-- Name: site_onboarding_upload; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_onboarding_upload (
    site_id character varying(25),
    s3_file_id integer,
    type character varying(255)
);


--
-- Name: site_onboarding_zendesk; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_onboarding_zendesk (
    site_id character varying(25),
    user_id character varying(25),
    ticket_id character varying(25)
);


--
-- Name: site_org_update_tmp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_org_update_tmp (
    site_id character varying,
    site_name character varying,
    organization_id_old character varying,
    organization_name_old character varying,
    organization_id_new character varying,
    organization_name_new character varying,
    mcm_id character varying
);


--
-- Name: site_playlist_id_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_playlist_id_backup (
    site_id character varying(255),
    jw_playlist_id text,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_publisher_ad_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_publisher_ad_preferences (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    json json NOT NULL
);


--
-- Name: site_publisher_ad_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_publisher_ad_preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_publisher_ad_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_publisher_ad_preferences_id_seq OWNED BY public.site_publisher_ad_preferences.id;


--
-- Name: site_rev_share; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_rev_share (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    user_id character varying(255) NOT NULL,
    adjusted_at timestamp with time zone DEFAULT now() NOT NULL,
    adjustment_reason character varying(255),
    note text,
    rev_share integer,
    rev_share_video integer,
    rev_share_in_image integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_rev_share_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_rev_share_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_rev_share_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_rev_share_id_seq OWNED BY public.site_rev_share.id;


--
-- Name: site_rpm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_rpm (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    before_total numeric,
    after_total numeric
);


--
-- Name: site_rpm_guarantee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_rpm_guarantee (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    duration text NOT NULL,
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_rpm_guarantee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_rpm_guarantee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_rpm_guarantee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_rpm_guarantee_id_seq OWNED BY public.site_rpm_guarantee.id;


--
-- Name: site_rpm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_rpm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_rpm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_rpm_id_seq OWNED BY public.site_rpm.id;


--
-- Name: site_rpm_input_after; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_rpm_input_after (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    start_date date,
    end_date date,
    ad_layout_changes text
);


--
-- Name: site_rpm_input_after_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_rpm_input_after_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_rpm_input_after_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_rpm_input_after_id_seq OWNED BY public.site_rpm_input_after.id;


--
-- Name: site_rpm_input_before; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_rpm_input_before (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    use_for_performance_reports boolean NOT NULL,
    overall numeric,
    desktop numeric,
    mobile numeric,
    display numeric,
    video numeric,
    is_rps boolean DEFAULT false NOT NULL,
    sticky_outstream jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    content_ad jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    recipe_ad jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    footer jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    sidebar jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    sticky_sidebar jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    display_json jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    video_json jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    mobile_json jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    desktop_json jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb,
    overall_json jsonb DEFAULT '{"cpm": null, "rpm": null, "rps": null, "fillRate": null, "viewability": null, "impressionsPerPageView": null}'::jsonb
);


--
-- Name: site_rpm_input_before_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_rpm_input_before_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_rpm_input_before_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_rpm_input_before_id_seq OWNED BY public.site_rpm_input_before.id;


--
-- Name: site_rpm_rps_monthly; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_rpm_rps_monthly AS
 SELECT site_earnings_analytics.site_id,
    date_part('year'::text, site_earnings_analytics.start_date) AS year,
    (date_part('month'::text, site_earnings_analytics.start_date) - (1)::double precision) AS month,
    sum(site_earnings_analytics.total_earnings) AS earnings,
    sum(site_earnings_analytics.total_pageviews) AS pageviews,
    sum(site_earnings_analytics.total_sessions) AS sessions,
    round(((sum(site_earnings_analytics.rpm_rps_earnings) / NULLIF(sum(site_earnings_analytics.rpm_pageviews), (0)::numeric)) * (1000)::numeric), 2) AS rpm,
    round(((sum(site_earnings_analytics.rpm_rps_earnings) / NULLIF(sum(site_earnings_analytics.rps_sessions), (0)::numeric)) * (1000)::numeric), 2) AS rps
   FROM public.site_earnings_analytics
  GROUP BY site_earnings_analytics.site_id, (date_part('year'::text, site_earnings_analytics.start_date)), (date_part('month'::text, site_earnings_analytics.start_date) - (1)::double precision);


--
-- Name: site_rpm_rps_weekly; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.site_rpm_rps_weekly AS
 SELECT site_earnings_analytics.site_id,
    (date_trunc('week'::text, site_earnings_analytics.start_date) + '5 days'::interval) AS date,
    sum(site_earnings_analytics.total_earnings) AS earnings,
    sum(site_earnings_analytics.total_pageviews) AS pageviews,
    sum(site_earnings_analytics.total_sessions) AS sessions,
    round(((sum(site_earnings_analytics.rpm_rps_earnings) / NULLIF(sum(site_earnings_analytics.rpm_pageviews), (0)::numeric)) * (1000)::numeric), 2) AS rpm,
    round(((sum(site_earnings_analytics.rpm_rps_earnings) / NULLIF(sum(site_earnings_analytics.rps_sessions), (0)::numeric)) * (1000)::numeric), 2) AS rps
   FROM public.site_earnings_analytics
  WHERE (site_earnings_analytics.start_date = site_earnings_analytics.end_date)
  GROUP BY site_earnings_analytics.site_id, (date_trunc('week'::text, site_earnings_analytics.start_date) + '5 days'::interval);


--
-- Name: site_snapshot_20211201; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_snapshot_20211201 (
    id character varying(255),
    name character varying(100),
    url character varying(255),
    start_date date,
    install_date date,
    dashboard_start_date date,
    rev_share integer,
    rev_share_video integer,
    rev_share_in_image integer,
    service character varying(255),
    status character varying(255),
    version character varying(255),
    breakpoint_tablet integer,
    breakpoint_desktop integer,
    ad_manager character varying(255),
    ad_options json,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    in_image_zone character varying(255),
    velocity boolean,
    velocity_start_date date,
    velocity_cost numeric(12,6),
    jw boolean,
    jw_api_key character varying(255),
    jw_api_secret character varying(255),
    video_embed character varying(255),
    jw_property_id character varying(255),
    jw_player_id character varying(255),
    ads_txt text,
    gam character varying(255),
    tier character varying(32),
    video_default_player_type character varying(32),
    dropped_reason_id integer,
    override_embed_location boolean,
    autoplay_collapsible_enabled boolean,
    company_name text,
    ad_types json,
    video_ad_options json,
    non_standard_reason text,
    previous_ad_network character varying,
    ad_locations json,
    targeting text,
    jw_playlist_id character varying(20),
    footer_selector text
);


--
-- Name: site_snapshot_20211206; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_snapshot_20211206 (
    id character varying(255),
    name character varying(100),
    url character varying(255),
    start_date date,
    install_date date,
    dashboard_start_date date,
    rev_share integer,
    rev_share_video integer,
    rev_share_in_image integer,
    service character varying(255),
    status character varying(255),
    version character varying(255),
    breakpoint_tablet integer,
    breakpoint_desktop integer,
    ad_manager character varying(255),
    ad_options json,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    in_image_zone character varying(255),
    velocity boolean,
    velocity_start_date date,
    velocity_cost numeric(12,6),
    jw boolean,
    jw_api_key character varying(255),
    jw_api_secret character varying(255),
    video_embed character varying(255),
    jw_property_id character varying(255),
    jw_player_id character varying(255),
    ads_txt text,
    gam character varying(255),
    tier character varying(32),
    video_default_player_type character varying(32),
    dropped_reason_id integer,
    override_embed_location boolean,
    autoplay_collapsible_enabled boolean,
    company_name text,
    ad_types json,
    video_ad_options json,
    non_standard_reason text,
    previous_ad_network character varying,
    ad_locations json,
    targeting text,
    jw_playlist_id character varying(20),
    footer_selector text
);


--
-- Name: site_social_media_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_social_media_info (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    platform_name text NOT NULL,
    handle text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_social_media_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_social_media_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_social_media_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_social_media_info_id_seq OWNED BY public.site_social_media_info.id;


--
-- Name: site_style; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_style (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    style text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: site_style_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_style_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_style_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_style_id_seq OWNED BY public.site_style.id;


--
-- Name: site_tier_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_tier_update (
    site_id character varying(255),
    tier character varying(32)
);


--
-- Name: site_tier_update_20221025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_tier_update_20221025 (
    id character varying(255),
    tier character varying(255)
);


--
-- Name: site_tracker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_tracker (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    enabled boolean DEFAULT true NOT NULL,
    user_id text
);


--
-- Name: site_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_user (
    site_id character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_vertical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_vertical (
    site_id character varying(255) NOT NULL,
    vertical_id character varying(255) NOT NULL,
    sequence integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: site_video_ad_player; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_video_ad_player (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    title character varying(100) NOT NULL,
    description character varying(1000) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    type character varying(50) NOT NULL,
    devices character varying(1000) NOT NULL,
    properties jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: site_video_ad_player_backup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_video_ad_player_backup (
    id integer,
    site_id character varying(24),
    title character varying(100),
    description character varying(1000),
    enabled boolean,
    type character varying(50),
    devices character varying(1000),
    properties jsonb,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: site_video_ad_player_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_video_ad_player_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_video_ad_player_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_video_ad_player_id_seq OWNED BY public.site_video_ad_player.id;


--
-- Name: site_video_sitemap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_video_sitemap (
    site_id character varying(24) NOT NULL,
    should_update boolean DEFAULT false NOT NULL,
    generated_at timestamp with time zone
);


--
-- Name: sites_tracker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites_tracker (
    site_id character varying(24) NOT NULL,
    site_tracker_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: snowflake_rpm_by_page_path_traffic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snowflake_rpm_by_page_path_traffic (
    date date NOT NULL,
    site_id character varying(24) NOT NULL,
    page_path text,
    traffic_source character varying(255),
    gross_revenue numeric NOT NULL,
    impressions bigint NOT NULL,
    unfilled_impressions bigint NOT NULL,
    viewable_impressions bigint NOT NULL,
    measurable_impressions bigint NOT NULL,
    pageviews numeric NOT NULL,
    sessions numeric NOT NULL,
    unique_pageviews numeric NOT NULL,
    exits numeric NOT NULL,
    bounces numeric NOT NULL,
    time_on_page numeric NOT NULL,
    session_duration numeric NOT NULL
);


--
-- Name: temp_dfp_order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_dfp_order (
    id character varying(10),
    name character varying(150),
    status character varying(20),
    is_archived integer,
    order_group character varying(20)
);


--
-- Name: temp_site_ad_layout_every_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_site_ad_layout_every_update (
    id character varying(255),
    original_json jsonb,
    update_json jsonb
);


--
-- Name: temp_site_ad_layout_max_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_site_ad_layout_max_update (
    id character varying(255),
    original_json jsonb,
    update_json jsonb
);


--
-- Name: test_site_earning_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_site_earning_source (
    date date NOT NULL,
    site_id character varying(255) NOT NULL,
    ad_network_id character varying(255) NOT NULL,
    ad_unit character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    impressions integer,
    viewable_impressions integer,
    earnings numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    clicks integer,
    gross_earnings numeric(12,6),
    manual boolean DEFAULT false,
    measurable_impressions integer,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    unfilled_impressions integer,
    impression_opportunities integer
);


--
-- Name: tmp_gam_unfilled_impressions_2021_02_23; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmp_gam_unfilled_impressions_2021_02_23 (
    date date,
    ad_unit_1 character varying(255),
    ad_unit_2 character varying(255),
    device character varying(255),
    adblock_recovery character varying(50),
    ad_unit_1_id character varying(255),
    ad_unit_2_id character varying(255),
    device_category_id character varying(255),
    adblock_recovery_id character varying(255),
    ad_unit_code character varying(255),
    unfilled_impressions integer
);


--
-- Name: type_publisher_application_analytics_account_ga_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_publisher_application_analytics_account_ga_type (
    name character varying(3) NOT NULL
);


--
-- Name: type_site_content_brief_language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_site_content_brief_language (
    name text NOT NULL
);


--
-- Name: type_site_content_brief_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_site_content_brief_status (
    name text NOT NULL
);


--
-- Name: type_site_content_brief_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_site_content_brief_type (
    name text NOT NULL
);


--
-- Name: type_site_keyword_recommendation_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_site_keyword_recommendation_status (
    name text NOT NULL
);


--
-- Name: type_site_keyword_recommendation_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_site_keyword_recommendation_type (
    name text NOT NULL
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id character varying(255) NOT NULL,
    name character varying(255),
    email character varying(255),
    inactive boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    type character varying(255),
    access character varying(25),
    user_role_id integer,
    birthday date,
    first_name text,
    last_name text,
    bio text,
    hobbies text,
    pronouns character varying(30),
    picture_url text,
    oauth_picture_pulled_at date
);


--
-- Name: user_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_contact (
    contact_id numeric NOT NULL,
    user_id character varying(24),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_contact_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_contact_info (
    id integer NOT NULL,
    user_id character varying(24) NOT NULL,
    email text,
    phone text,
    address_line_1 text,
    address_line_2 text,
    city text,
    zone text,
    postal_code text,
    country_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_contact_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_contact_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_contact_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_contact_info_id_seq OWNED BY public.user_contact_info.id;


--
-- Name: user_feedback_and_testing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_feedback_and_testing (
    id integer NOT NULL,
    user_id character varying(24) NOT NULL,
    on_innovation_council boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    in_ad_code_beta boolean DEFAULT false NOT NULL
);


--
-- Name: user_feedback_and_testing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_feedback_and_testing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedback_and_testing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_feedback_and_testing_id_seq OWNED BY public.user_feedback_and_testing.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    START WITH 5000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: user_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_permission (
    user_id character varying(255) NOT NULL,
    permission_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_role (
    user_id character varying(255) NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    site_id character varying(24)
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    type text NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_settings (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_settings_id_seq OWNED BY public.user_settings.id;


--
-- Name: user_site_role_import_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_site_role_import_staging (
    user_id text,
    user_email text,
    site_id text,
    role text,
    staging_batch_num integer,
    final_role_id integer,
    "timestamp" timestamp with time zone DEFAULT now()
);


--
-- Name: user_tc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tc (
    user_id character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    accepted boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    data text,
    type character varying(255) DEFAULT 'serviceAgreement'::character varying NOT NULL
);


--
-- Name: vertical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vertical (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255),
    inactive boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: video_cpm_by_site_2021_04_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_cpm_by_site_2021_04_12 (
    site_id character varying(255),
    cpm numeric
);


--
-- Name: video_rev_adjustment_2021_04_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_rev_adjustment_2021_04_12 (
    site_id character varying(255),
    cpm numeric,
    codeserves integer,
    impressions integer,
    gross_earnings numeric,
    rev_share_video integer,
    publisher_earnings numeric
);


--
-- Name: video_sidebar_playlist_migration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_sidebar_playlist_migration (
    id integer NOT NULL,
    site_id character varying(24) NOT NULL,
    jw_site_id character varying(10) NOT NULL,
    dynamic_playlist_id character varying(10),
    manual_playlist_id character varying(10),
    media_ids character varying(10)[],
    last_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: video_sidebar_playlist_migration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.video_sidebar_playlist_migration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: video_sidebar_playlist_migration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.video_sidebar_playlist_migration_id_seq OWNED BY public.video_sidebar_playlist_migration.id;


--
-- Name: zendesk_ticket_zendesk_macro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zendesk_ticket_zendesk_macro (
    id integer NOT NULL,
    zendesk_ticket_id character varying(255) NOT NULL,
    zendesk_macro_id character varying(255) NOT NULL,
    created_at character varying(255) DEFAULT now() NOT NULL
);


--
-- Name: zendesk_ticket_zendesk_macro_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.zendesk_ticket_zendesk_macro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zendesk_ticket_zendesk_macro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zendesk_ticket_zendesk_macro_id_seq OWNED BY public.zendesk_ticket_zendesk_macro.id;


--
-- Name: zendesk_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zendesk_tickets (
    id character varying(255) NOT NULL,
    created_at character varying(255) DEFAULT now()
);


--
-- Name: ad_code_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_code_config ALTER COLUMN id SET DEFAULT nextval('public.ad_code_config_id_seq'::regclass);


--
-- Name: ad_location id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_location ALTER COLUMN id SET DEFAULT nextval('public.adlocationsequence'::regclass);


--
-- Name: ad_partner id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_partner ALTER COLUMN id SET DEFAULT nextval('public.ad_partner_id_seq'::regclass);


--
-- Name: alert id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert ALTER COLUMN id SET DEFAULT nextval('public.alert_id_seq'::regclass);


--
-- Name: alert_distribution_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_distribution_type ALTER COLUMN id SET DEFAULT nextval('public.alert_distribution_type_id_seq'::regclass);


--
-- Name: alert_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_type ALTER COLUMN id SET DEFAULT nextval('public.alert_type_id_seq'::regclass);


--
-- Name: application_ad_network id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_ad_network ALTER COLUMN id SET DEFAULT nextval('public.application_ad_network_id_seq'::regclass);


--
-- Name: change_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_history ALTER COLUMN id SET DEFAULT nextval('public.change_history_id_seq'::regclass);


--
-- Name: cms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms ALTER COLUMN id SET DEFAULT nextval('public.cms_id_seq'::regclass);


--
-- Name: content_optimization_algorithm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_optimization_algorithm ALTER COLUMN id SET DEFAULT nextval('public.content_optimization_algorithm_id_seq'::regclass);


--
-- Name: data_source id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_source ALTER COLUMN id SET DEFAULT nextval('public.data_source_sequence'::regclass);


--
-- Name: default_ad_layout id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_ad_layout ALTER COLUMN id SET DEFAULT nextval('public.default_ad_layout_id_seq'::regclass);


--
-- Name: default_video_ad_player id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_video_ad_player ALTER COLUMN id SET DEFAULT nextval('public.default_video_ad_player_id_seq'::regclass);


--
-- Name: dropped_reason id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dropped_reason ALTER COLUMN id SET DEFAULT nextval('public.dropped_reason_id_seq'::regclass);


--
-- Name: dropped_reason_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dropped_reason_category ALTER COLUMN id SET DEFAULT nextval('public.dropped_reason_category_id_seq'::regclass);


--
-- Name: entity_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_settings ALTER COLUMN id SET DEFAULT nextval('public.entity_settings_id_seq'::regclass);


--
-- Name: feature_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_flags ALTER COLUMN id SET DEFAULT nextval('public.feature_flags_id_seq'::regclass);


--
-- Name: job id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job ALTER COLUMN id SET DEFAULT nextval('public.job_id_seq'::regclass);


--
-- Name: job_issue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_issue ALTER COLUMN id SET DEFAULT nextval('public.job_issue_id_seq'::regclass);


--
-- Name: knex_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations ALTER COLUMN id SET DEFAULT nextval('public.knex_migrations_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: mcm_child_publisher id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_child_publisher ALTER COLUMN id SET DEFAULT nextval('public.mcm_child_publisher_id_seq'::regclass);


--
-- Name: mcm_migration_child_publisher id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_child_publisher ALTER COLUMN id SET DEFAULT nextval('public.mcm_migration_child_publisher_id_seq'::regclass);


--
-- Name: mcm_migration_reminder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_reminder ALTER COLUMN id SET DEFAULT nextval('public.mcm_migration_reminder_id_seq'::regclass);


--
-- Name: mcm_migration_site id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_site ALTER COLUMN id SET DEFAULT nextval('public.mcm_migration_site_id_seq'::regclass);


--
-- Name: mcm_migration_staging id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_staging ALTER COLUMN id SET DEFAULT nextval('public.mcm_migration_staging_id_seq'::regclass);


--
-- Name: note_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_status ALTER COLUMN id SET DEFAULT nextval('public.note_status_id_seq'::regclass);


--
-- Name: note_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types ALTER COLUMN id SET DEFAULT nextval('public.note_types_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: organization_demographic_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_demographic_info ALTER COLUMN id SET DEFAULT nextval('public.organization_demographic_info_id_seq'::regclass);


--
-- Name: permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission ALTER COLUMN id SET DEFAULT nextval('public.permission_id_seq'::regclass);


--
-- Name: publisher_application id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application ALTER COLUMN id SET DEFAULT nextval('public.publisher_application_id_seq'::regclass);


--
-- Name: publisher_dashboard_today_override id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_dashboard_today_override ALTER COLUMN id SET DEFAULT nextval('public.publisher_dashboard_today_override_id_seq'::regclass);


--
-- Name: revenue_adjustment_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revenue_adjustment_history ALTER COLUMN id SET DEFAULT nextval('public.revenue_adjustment_history_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Name: s3_bucket id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_bucket ALTER COLUMN id SET DEFAULT nextval('public.s3_bucket_id_seq'::regclass);


--
-- Name: s3_file id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_file ALTER COLUMN id SET DEFAULT nextval('public.s3_file_id_seq'::regclass);


--
-- Name: site_ad_density_override id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_density_override ALTER COLUMN id SET DEFAULT nextval('public.site_ad_density_override_id_seq'::regclass);


--
-- Name: site_ad_layout id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_layout ALTER COLUMN id SET DEFAULT nextval('public.site_ad_layout_id_seq'::regclass);


--
-- Name: site_alert id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert ALTER COLUMN id SET DEFAULT nextval('public.site_alert_id_seq'::regclass);


--
-- Name: site_alert_closed id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert_closed ALTER COLUMN id SET DEFAULT nextval('public.site_alert_closed_id_seq'::regclass);


--
-- Name: site_demographic_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_demographic_info ALTER COLUMN id SET DEFAULT nextval('public.site_demographic_info_id_seq'::regclass);


--
-- Name: site_gsc_auth id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_gsc_auth ALTER COLUMN id SET DEFAULT nextval('public.site_gsc_auth_id_seq'::regclass);


--
-- Name: site_guided_action id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_guided_action ALTER COLUMN id SET DEFAULT nextval('public.site_guided_action_id_seq'::regclass);


--
-- Name: site_keyword_recommendation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_keyword_recommendation ALTER COLUMN id SET DEFAULT nextval('public.site_keyword_recommendation_id_seq'::regclass);


--
-- Name: site_offboarding id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_offboarding ALTER COLUMN id SET DEFAULT nextval('public.site_offboarding_id_seq'::regclass);


--
-- Name: site_publisher_ad_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_publisher_ad_preferences ALTER COLUMN id SET DEFAULT nextval('public.site_publisher_ad_preferences_id_seq'::regclass);


--
-- Name: site_rev_share id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rev_share ALTER COLUMN id SET DEFAULT nextval('public.site_rev_share_id_seq'::regclass);


--
-- Name: site_rpm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm ALTER COLUMN id SET DEFAULT nextval('public.site_rpm_id_seq'::regclass);


--
-- Name: site_rpm_guarantee id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_guarantee ALTER COLUMN id SET DEFAULT nextval('public.site_rpm_guarantee_id_seq'::regclass);


--
-- Name: site_rpm_input_after id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_input_after ALTER COLUMN id SET DEFAULT nextval('public.site_rpm_input_after_id_seq'::regclass);


--
-- Name: site_rpm_input_before id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_input_before ALTER COLUMN id SET DEFAULT nextval('public.site_rpm_input_before_id_seq'::regclass);


--
-- Name: site_social_media_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_social_media_info ALTER COLUMN id SET DEFAULT nextval('public.site_social_media_info_id_seq'::regclass);


--
-- Name: site_style id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_style ALTER COLUMN id SET DEFAULT nextval('public.site_style_id_seq'::regclass);


--
-- Name: site_video_ad_player id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_video_ad_player ALTER COLUMN id SET DEFAULT nextval('public.site_video_ad_player_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT lpad((nextval('public.user_id_seq'::regclass))::text, 24, '0'::text);


--
-- Name: user_contact_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact_info ALTER COLUMN id SET DEFAULT nextval('public.user_contact_info_id_seq'::regclass);


--
-- Name: user_feedback_and_testing id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback_and_testing ALTER COLUMN id SET DEFAULT nextval('public.user_feedback_and_testing_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: user_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings ALTER COLUMN id SET DEFAULT nextval('public.user_settings_id_seq'::regclass);


--
-- Name: video_sidebar_playlist_migration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_sidebar_playlist_migration ALTER COLUMN id SET DEFAULT nextval('public.video_sidebar_playlist_migration_id_seq'::regclass);


--
-- Name: zendesk_ticket_zendesk_macro id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zendesk_ticket_zendesk_macro ALTER COLUMN id SET DEFAULT nextval('public.zendesk_ticket_zendesk_macro_id_seq'::regclass);


--
-- Name: ad_code_config ad_code_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_code_config
    ADD CONSTRAINT ad_code_config_pkey PRIMARY KEY (id);


--
-- Name: ad_host ad_host_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_host
    ADD CONSTRAINT ad_host_pkey PRIMARY KEY (site_id);


--
-- Name: ad_layout_published ad_layout_published_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_layout_published
    ADD CONSTRAINT ad_layout_published_pkey PRIMARY KEY (site_id);


--
-- Name: ad_location_ad_size ad_location_ad_size_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_location_ad_size
    ADD CONSTRAINT ad_location_ad_size_pkey PRIMARY KEY (ad_location_id, ad_size_id);


--
-- Name: ad_location ad_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_location
    ADD CONSTRAINT ad_location_pkey PRIMARY KEY (id);


--
-- Name: ad_network_device ad_network_device_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_network_device
    ADD CONSTRAINT ad_network_device_pkey PRIMARY KEY (id, ad_network_id);


--
-- Name: ad_page_campaign ad_page_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_page_campaign
    ADD CONSTRAINT ad_page_campaign_pkey PRIMARY KEY (url);


--
-- Name: ad_partner ad_partner_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_partner
    ADD CONSTRAINT ad_partner_key_key UNIQUE (key);


--
-- Name: ad_partner ad_partner_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_partner
    ADD CONSTRAINT ad_partner_pkey PRIMARY KEY (id);


--
-- Name: ad_size ad_size_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_size
    ADD CONSTRAINT ad_size_pkey PRIMARY KEY (id);


--
-- Name: ad_size ad_size_width_height_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_size
    ADD CONSTRAINT ad_size_width_height_unique UNIQUE (width, height);


--
-- Name: ad_unit ad_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_unit
    ADD CONSTRAINT ad_unit_pkey PRIMARY KEY (id);


--
-- Name: ad_unit_temp ad_unit_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_unit_temp
    ADD CONSTRAINT ad_unit_temp_pkey PRIMARY KEY (id);


--
-- Name: adthrive_dfp_bucket_earning adthrive_dfp_bucket_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_bucket_earning
    ADD CONSTRAINT adthrive_dfp_bucket_earning_pkey PRIMARY KEY (date, ad_unit_1_id, ad_unit_2_id, ad_unit_code, device, bucket);


--
-- Name: adthrive_dfp_earning_dimension adthrive_dfp_earning_dimension_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning_dimension
    ADD CONSTRAINT adthrive_dfp_earning_dimension_pkey PRIMARY KEY (date, order_name, ad_unit_1, ad_unit_2, ad_unit_code, dimension, key, value);


--
-- Name: adthrive_dfp_earning adthrive_dfp_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning
    ADD CONSTRAINT adthrive_dfp_earning_pkey PRIMARY KEY (date, order_name, ad_unit_1, ad_unit_2, ad_unit_code, device);


--
-- Name: adthrive_dfp_earning_temp adthrive_dfp_earning_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning_temp
    ADD CONSTRAINT adthrive_dfp_earning_temp_pkey PRIMARY KEY (date, order_name, ad_unit_1, ad_unit_2, ad_unit_code, device);


--
-- Name: adthrive_dfp_impression_device_dimension adthrive_dfp_impression_device_dimension_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_impression_device_dimension
    ADD CONSTRAINT adthrive_dfp_impression_device_dimension_pkey PRIMARY KEY (date, ad_unit_1, ad_unit_2, ad_unit_code, device, dimension, key, value);


--
-- Name: adthrive_dfp_refresh_earning adthrive_dfp_refresh_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_refresh_earning
    ADD CONSTRAINT adthrive_dfp_refresh_earning_pkey PRIMARY KEY (date, ad_unit_1_id, ad_unit_2_id, ad_unit_code, device, refresh);


--
-- Name: adthrive_gam_adx_deals_temp adthrive_gam_adx_deals_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gam_adx_deals_temp
    ADD CONSTRAINT adthrive_gam_adx_deals_temp_pkey PRIMARY KEY (date, ad_unit_1_id, ad_unit_2_id, ad_unit_code, device, advertiser_name, deal_id);


--
-- Name: adthrive_gam_by_source adthrive_gam_by_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gam_by_source
    ADD CONSTRAINT adthrive_gam_by_source_pkey PRIMARY KEY (date, ad_unit_1_id, ad_unit_2_id, ad_unit_code, referrer);


--
-- Name: adthrive_gam_earning adthrive_gam_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gam_earning
    ADD CONSTRAINT adthrive_gam_earning_pkey PRIMARY KEY (date, ad_network_id, ad_unit_1_id, ad_unit_2_id, ad_unit_code, device, adblock_recovery);


--
-- Name: adthrive_gam_earning_old adthrive_gam_earning_pkey_old; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gam_earning_old
    ADD CONSTRAINT adthrive_gam_earning_pkey_old PRIMARY KEY (date, ad_network_id, ad_unit_1_id, ad_unit_2_id, ad_unit_code, device, adblock_publica);


--
-- Name: adthrive_gum_gum_earning adthrive_gum_gum_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gum_gum_earning
    ADD CONSTRAINT adthrive_gum_gum_earning_pkey PRIMARY KEY (date, device, zone_id);


--
-- Name: adthrive_sekindo_earning adthrive_sekindo_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_sekindo_earning
    ADD CONSTRAINT adthrive_sekindo_earning_pkey PRIMARY KEY (date, sub_id, space_name, device_type);


--
-- Name: alert_distribution_type alert_distribution_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_distribution_type
    ADD CONSTRAINT alert_distribution_type_pkey PRIMARY KEY (id);


--
-- Name: alert alert_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert
    ADD CONSTRAINT alert_pkey PRIMARY KEY (id);


--
-- Name: alert_type alert_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_type
    ADD CONSTRAINT alert_type_pkey PRIMARY KEY (id);


--
-- Name: application_account application_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_account
    ADD CONSTRAINT application_account_pkey PRIMARY KEY (application_id, account_id, web_property_id, profile_id);


--
-- Name: application_ad_network application_ad_network_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_ad_network
    ADD CONSTRAINT application_ad_network_pkey PRIMARY KEY (id);


--
-- Name: application_analytic_account_country application_analytic_account_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_country
    ADD CONSTRAINT application_analytic_account_country_pkey PRIMARY KEY (application_id, date, account, country);


--
-- Name: application_analytic_account_device_category application_analytic_account_device_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_device_category
    ADD CONSTRAINT application_analytic_account_device_category_pkey PRIMARY KEY (application_id, date, account, device_category);


--
-- Name: application_analytic_account_page_title application_analytic_account_page_title_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_page_title
    ADD CONSTRAINT application_analytic_account_page_title_pkey PRIMARY KEY (application_id, date, account, page_title);


--
-- Name: application_analytic_account application_analytic_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account
    ADD CONSTRAINT application_analytic_account_pkey PRIMARY KEY (application_id, date, account);


--
-- Name: application_analytic_account_source application_analytic_account_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_source
    ADD CONSTRAINT application_analytic_account_source_pkey PRIMARY KEY (application_id, date, account, source);


--
-- Name: application application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_pkey PRIMARY KEY (id);


--
-- Name: brief_performance_summary brief_performance_summary_brief_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brief_performance_summary
    ADD CONSTRAINT brief_performance_summary_brief_id_key UNIQUE (brief_id);


--
-- Name: calendar calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (id);


--
-- Name: change_history change_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_history
    ADD CONSTRAINT change_history_pkey PRIMARY KEY (id);


--
-- Name: cms cms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms
    ADD CONSTRAINT cms_pkey PRIMARY KEY (id);


--
-- Name: content_optimization_algorithm content_optimization_algorithm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_optimization_algorithm
    ADD CONSTRAINT content_optimization_algorithm_pkey PRIMARY KEY (id);


--
-- Name: content_optimization_algorithm content_optimization_algorithm_version_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_optimization_algorithm
    ADD CONSTRAINT content_optimization_algorithm_version_name_key UNIQUE (version_name);


--
-- Name: content_optimization_onboarding content_optimization_onboarding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_optimization_onboarding
    ADD CONSTRAINT content_optimization_onboarding_pkey PRIMARY KEY (site_id);


--
-- Name: data_source data_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_source
    ADD CONSTRAINT data_source_pkey PRIMARY KEY (id);


--
-- Name: default_ad_layout default_ad_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_ad_layout
    ADD CONSTRAINT default_ad_layout_pkey PRIMARY KEY (id);


--
-- Name: default_video_ad_player default_video_ad_player_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_video_ad_player
    ADD CONSTRAINT default_video_ad_player_pkey PRIMARY KEY (id);


--
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- Name: dropped_reason_category dropped_reason_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dropped_reason_category
    ADD CONSTRAINT dropped_reason_category_pkey PRIMARY KEY (id);


--
-- Name: dropped_reason_category dropped_reason_category_text_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dropped_reason_category
    ADD CONSTRAINT dropped_reason_category_text_key UNIQUE (text);


--
-- Name: dropped_reason dropped_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dropped_reason
    ADD CONSTRAINT dropped_reason_pkey PRIMARY KEY (id);


--
-- Name: entity_settings entity_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_settings
    ADD CONSTRAINT entity_key_unique UNIQUE (entity_type, entity_id, key);


--
-- Name: entity_settings entity_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_settings
    ADD CONSTRAINT entity_settings_pkey PRIMARY KEY (id);


--
-- Name: feature_flags feature_flags_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_flags
    ADD CONSTRAINT feature_flags_name_key UNIQUE (name);


--
-- Name: feature_flags feature_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: gam_top_line gam_top_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gam_top_line
    ADD CONSTRAINT gam_top_line_pkey PRIMARY KEY (date);


--
-- Name: guided_action guided_action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guided_action
    ADD CONSTRAINT guided_action_pkey PRIMARY KEY (name);


--
-- Name: guided_action guided_action_priority_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guided_action
    ADD CONSTRAINT guided_action_priority_key UNIQUE (priority) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: job_issue job_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_issue
    ADD CONSTRAINT job_issue_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: knex_migrations knex_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations
    ADD CONSTRAINT knex_migrations_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: mcm_child_publisher mcm_child_publisher_company_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_child_publisher
    ADD CONSTRAINT mcm_child_publisher_company_id_key UNIQUE (company_id);


--
-- Name: mcm_child_publisher mcm_child_publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_child_publisher
    ADD CONSTRAINT mcm_child_publisher_pkey PRIMARY KEY (id);


--
-- Name: mcm_migration_child_publisher mcm_migration_child_publisher_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_child_publisher
    ADD CONSTRAINT mcm_migration_child_publisher_pkey PRIMARY KEY (id);


--
-- Name: mcm_migration_child_publisher mcm_migration_child_publisher_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_child_publisher
    ADD CONSTRAINT mcm_migration_child_publisher_user_id_key UNIQUE (user_id);


--
-- Name: mcm_migration_reminder mcm_migration_reminder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_reminder
    ADD CONSTRAINT mcm_migration_reminder_pkey PRIMARY KEY (id);


--
-- Name: mcm_migration_site mcm_migration_site_mcm_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_site
    ADD CONSTRAINT mcm_migration_site_mcm_id_key UNIQUE (mcm_id);


--
-- Name: mcm_migration_site mcm_migration_site_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_site
    ADD CONSTRAINT mcm_migration_site_pkey PRIMARY KEY (id);


--
-- Name: mcm_migration_site mcm_migration_site_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_site
    ADD CONSTRAINT mcm_migration_site_site_id_key UNIQUE (site_id);


--
-- Name: mcm_migration_staging mcm_migration_staging_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_staging
    ADD CONSTRAINT mcm_migration_staging_pkey PRIMARY KEY (id);


--
-- Name: note_attachments note_attachments_note_id_s3_file_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_attachments
    ADD CONSTRAINT note_attachments_note_id_s3_file_id_unique UNIQUE (note_id, s3_file_id);


--
-- Name: note_status note_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_status
    ADD CONSTRAINT note_status_pkey PRIMARY KEY (id);


--
-- Name: note_types note_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_types
    ADD CONSTRAINT note_types_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: organization_demographic_info organization_demographic_info_organization_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_demographic_info
    ADD CONSTRAINT organization_demographic_info_organization_id_key UNIQUE (organization_id);


--
-- Name: organization_demographic_info organization_demographic_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_demographic_info
    ADD CONSTRAINT organization_demographic_info_pkey PRIMARY KEY (id);


--
-- Name: organization organization_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_name_unique UNIQUE (name);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: organization_user organization_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_pkey PRIMARY KEY (organization_id, user_id);


--
-- Name: permission permission_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_key_key UNIQUE (key);


--
-- Name: permission permission_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_name_key UNIQUE (name);


--
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (id);


--
-- Name: primis_ad_server_report primis_ad_server_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.primis_ad_server_report
    ADD CONSTRAINT primis_ad_server_report_pkey PRIMARY KEY (date, domain, hb_partner, device_type, placement_id, placement_name);


--
-- Name: primis_ad_server_revenue_adjustment primis_ad_server_revenue_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.primis_ad_server_revenue_adjustment
    ADD CONSTRAINT primis_ad_server_revenue_adjustment_pkey PRIMARY KEY (date);


--
-- Name: primis_earning primis_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.primis_earning
    ADD CONSTRAINT primis_earning_pkey PRIMARY KEY (date, site_id, space_name, device_type);


--
-- Name: primis_media_report primis_media_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.primis_media_report
    ADD CONSTRAINT primis_media_report_pkey PRIMARY KEY (date, sub_id, domain, device_type, placement_id, placement_name);


--
-- Name: publisher_application_analytics_account publisher_application_analytics_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_account
    ADD CONSTRAINT publisher_application_analytics_account_pkey PRIMARY KEY (publisher_application_id, account_id, web_property_id, profile_id);


--
-- Name: publisher_application_analytics_profile_by_country publisher_application_analytics_profile_by_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_country
    ADD CONSTRAINT publisher_application_analytics_profile_by_country_pkey PRIMARY KEY (date, publisher_application_id, analytics_profile_id, country);


--
-- Name: publisher_application_analytics_profile_by_date publisher_application_analytics_profile_by_date_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_date
    ADD CONSTRAINT publisher_application_analytics_profile_by_date_pkey PRIMARY KEY (date, publisher_application_id, analytics_profile_id);


--
-- Name: publisher_application_analytics_profile_by_device publisher_application_analytics_profile_by_device_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_device
    ADD CONSTRAINT publisher_application_analytics_profile_by_device_pkey PRIMARY KEY (date, publisher_application_id, analytics_profile_id, device_category);


--
-- Name: publisher_application_analytics_profile_by_page_title publisher_application_analytics_profile_by_page_title_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_page_title
    ADD CONSTRAINT publisher_application_analytics_profile_by_page_title_pkey PRIMARY KEY (date, publisher_application_id, analytics_profile_id, page_title, page_path);


--
-- Name: publisher_application_analytics_profile_by_source publisher_application_analytics_profile_by_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_source
    ADD CONSTRAINT publisher_application_analytics_profile_by_source_pkey PRIMARY KEY (date, publisher_application_id, analytics_profile_id, source);


--
-- Name: publisher_application publisher_application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application
    ADD CONSTRAINT publisher_application_pkey PRIMARY KEY (id);


--
-- Name: publisher_application_vertical publisher_application_vertical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_vertical
    ADD CONSTRAINT publisher_application_vertical_pkey PRIMARY KEY (publisher_application_id, vertical_id);


--
-- Name: publisher_dashboard_today_override publisher_dashboard_today_override_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_dashboard_today_override
    ADD CONSTRAINT publisher_dashboard_today_override_pkey PRIMARY KEY (id);


--
-- Name: request_log request_log_new_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_log
    ADD CONSTRAINT request_log_new_pkey PRIMARY KEY (id);


--
-- Name: request_log_old request_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_log_old
    ADD CONSTRAINT request_log_pkey PRIMARY KEY (id);


--
-- Name: revenue_adjustment_history revenue_adjustment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revenue_adjustment_history
    ADD CONSTRAINT revenue_adjustment_history_pkey PRIMARY KEY (id);


--
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: s3_bucket s3_bucket_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_bucket
    ADD CONSTRAINT s3_bucket_name_unique UNIQUE (name);


--
-- Name: s3_bucket s3_bucket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_bucket
    ADD CONSTRAINT s3_bucket_pkey PRIMARY KEY (id);


--
-- Name: s3_file s3_file_bucket_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_file
    ADD CONSTRAINT s3_file_bucket_id_key_unique UNIQUE (bucket_id, key);


--
-- Name: s3_file s3_file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_file
    ADD CONSTRAINT s3_file_pkey PRIMARY KEY (id);


--
-- Name: site_ad_density_enabled site_ad_density_enabled_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_density_enabled
    ADD CONSTRAINT site_ad_density_enabled_pkey PRIMARY KEY (site_id);


--
-- Name: site_ad_density_meta site_ad_density_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_density_meta
    ADD CONSTRAINT site_ad_density_meta_pkey PRIMARY KEY (site_id);


--
-- Name: site_ad_density_override site_ad_density_override_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_density_override
    ADD CONSTRAINT site_ad_density_override_pkey PRIMARY KEY (id);


--
-- Name: site_ad_density site_ad_density_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_density
    ADD CONSTRAINT site_ad_density_pkey PRIMARY KEY (site_id, device);


--
-- Name: site_ad_layout_meta site_ad_layout_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_layout_meta
    ADD CONSTRAINT site_ad_layout_meta_pkey PRIMARY KEY (site_id);


--
-- Name: site_ad_layout site_ad_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_layout
    ADD CONSTRAINT site_ad_layout_pkey PRIMARY KEY (id);


--
-- Name: site_ad_network_earning site_ad_network_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_network_earning
    ADD CONSTRAINT site_ad_network_earning_pkey PRIMARY KEY (date, site_id, ad_unit, device);


--
-- Name: site_ad_sense_earning_domain site_ad_sense_earning_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_sense_earning_domain
    ADD CONSTRAINT site_ad_sense_earning_domain_pkey PRIMARY KEY (date, site_id, device, domain);


--
-- Name: site_ad_sense_earning site_ad_sense_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_sense_earning
    ADD CONSTRAINT site_ad_sense_earning_pkey PRIMARY KEY (date, site_id, ad_unit, device);


--
-- Name: site_alert_closed site_alert_closed_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert_closed
    ADD CONSTRAINT site_alert_closed_pkey PRIMARY KEY (id);


--
-- Name: site_alert_closed site_alert_closed_site_id_alert_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert_closed
    ADD CONSTRAINT site_alert_closed_site_id_alert_id_unique UNIQUE (site_id, alert_id);


--
-- Name: site_alert site_alert_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert
    ADD CONSTRAINT site_alert_pkey PRIMARY KEY (id);


--
-- Name: site_alert site_alert_site_id_alert_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert
    ADD CONSTRAINT site_alert_site_id_alert_id_unique UNIQUE (site_id, alert_id);


--
-- Name: site_analytic_account_country site_analytic_account_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_country
    ADD CONSTRAINT site_analytic_account_country_pkey PRIMARY KEY (site_id, date, account, country);


--
-- Name: site_analytic_account_country_temp site_analytic_account_country_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_country_temp
    ADD CONSTRAINT site_analytic_account_country_temp_pkey PRIMARY KEY (site_id, date, account, country);


--
-- Name: site_analytic_account_device_category site_analytic_account_device_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_device_category
    ADD CONSTRAINT site_analytic_account_device_category_pkey PRIMARY KEY (site_id, date, account, device_category);


--
-- Name: site_analytic_account_device_category_temp site_analytic_account_device_category_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_device_category_temp
    ADD CONSTRAINT site_analytic_account_device_category_temp_pkey PRIMARY KEY (site_id, date, account, device_category);


--
-- Name: site_analytic_account_dimension site_analytic_account_dimension_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_dimension
    ADD CONSTRAINT site_analytic_account_dimension_pkey PRIMARY KEY (site_id, date, account, name, value);


--
-- Name: site_analytic_account site_analytic_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account
    ADD CONSTRAINT site_analytic_account_pkey PRIMARY KEY (site_id, date, account);


--
-- Name: site_analytic_account_social_network site_analytic_account_social_network_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_social_network
    ADD CONSTRAINT site_analytic_account_social_network_pkey PRIMARY KEY (site_id, date, account, social_network);


--
-- Name: site_analytic_account_social_network_temp site_analytic_account_social_network_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_social_network_temp
    ADD CONSTRAINT site_analytic_account_social_network_temp_pkey PRIMARY KEY (site_id, date, account, social_network);


--
-- Name: site_analytic_account_source site_analytic_account_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_source
    ADD CONSTRAINT site_analytic_account_source_pkey PRIMARY KEY (site_id, date, account, source);


--
-- Name: site_analytic_account_source_temp site_analytic_account_source_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_source_temp
    ADD CONSTRAINT site_analytic_account_source_temp_pkey PRIMARY KEY (site_id, date, account, source);


--
-- Name: site_analytic_account_speed site_analytic_account_speed_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_speed
    ADD CONSTRAINT site_analytic_account_speed_pkey PRIMARY KEY (site_id, date, account);


--
-- Name: site_analytic_account_temp site_analytic_account_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_temp
    ADD CONSTRAINT site_analytic_account_temp_pkey PRIMARY KEY (site_id, date, account);


--
-- Name: site_authorization site_authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_authorization
    ADD CONSTRAINT site_authorization_pkey PRIMARY KEY (id);


--
-- Name: site_cms site_cms_site_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_cms
    ADD CONSTRAINT site_cms_site_id_unique UNIQUE (site_id);


--
-- Name: site_company_temp site_company_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_company_temp
    ADD CONSTRAINT site_company_temp_pkey PRIMARY KEY (site_id);


--
-- Name: site_competitors site_competitors_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_competitors
    ADD CONSTRAINT site_competitors_site_id_key UNIQUE (site_id);


--
-- Name: site_config_activity site_config_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_config_activity
    ADD CONSTRAINT site_config_activity_pkey PRIMARY KEY (site_id, config_name);


--
-- Name: site_content_brief site_content_brief_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content_brief
    ADD CONSTRAINT site_content_brief_pkey PRIMARY KEY (id);


--
-- Name: site_data_source site_data_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_data_source
    ADD CONSTRAINT site_data_source_pkey PRIMARY KEY (id);


--
-- Name: site_demographic_info site_demographic_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_demographic_info
    ADD CONSTRAINT site_demographic_info_pkey PRIMARY KEY (id);


--
-- Name: site_demographic_info site_demographic_info_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_demographic_info
    ADD CONSTRAINT site_demographic_info_site_id_key UNIQUE (site_id);


--
-- Name: site_earning_source site_earning_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_earning_source
    ADD CONSTRAINT site_earning_source_pkey PRIMARY KEY (date, site_id, ad_network_id, ad_unit, device, source, note);


--
-- Name: site_experiment_data site_experiment_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_experiment_data
    ADD CONSTRAINT site_experiment_data_pkey PRIMARY KEY (date, site_id, experiment_id, variant, device);


--
-- Name: site_gsc_auth site_gsc_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_gsc_auth
    ADD CONSTRAINT site_gsc_auth_pkey PRIMARY KEY (id);


--
-- Name: site_gsc_auth site_gsc_auth_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_gsc_auth
    ADD CONSTRAINT site_gsc_auth_site_id_key UNIQUE (site_id);


--
-- Name: site_guided_action site_guided_action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_guided_action
    ADD CONSTRAINT site_guided_action_pkey PRIMARY KEY (id);


--
-- Name: site_jw_analytic site_jw_analytic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_jw_analytic
    ADD CONSTRAINT site_jw_analytic_pkey PRIMARY KEY (date, site_id, device_type, media_id, player_id);


--
-- Name: site_jw_player site_jw_player_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_jw_player
    ADD CONSTRAINT site_jw_player_pkey PRIMARY KEY (id, site_id);


--
-- Name: site_jw_video site_jw_video_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_jw_video
    ADD CONSTRAINT site_jw_video_pkey PRIMARY KEY (id, site_id);


--
-- Name: site_keyword_recommendation site_keyword_recommendation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_keyword_recommendation
    ADD CONSTRAINT site_keyword_recommendation_pkey PRIMARY KEY (id);


--
-- Name: site_monthly_analytic site_monthly_analytic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_analytic
    ADD CONSTRAINT site_monthly_analytic_pkey PRIMARY KEY (site_id, year, month);


--
-- Name: site_monthly_earning site_monthly_earning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_earning
    ADD CONSTRAINT site_monthly_earning_pkey PRIMARY KEY (year, month, site_id, ad_network_id);


--
-- Name: site_monthly_metric site_monthly_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_metric
    ADD CONSTRAINT site_monthly_metric_pkey PRIMARY KEY (site_id, data_source_id, year, month, manual);


--
-- Name: site site_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_name_unique UNIQUE (name);


--
-- Name: site_offboarding site_offboarding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_offboarding
    ADD CONSTRAINT site_offboarding_pkey PRIMARY KEY (id);


--
-- Name: site_onboarding_ad_goals site_onboarding_ad_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_ad_goals
    ADD CONSTRAINT site_onboarding_ad_goals_pkey PRIMARY KEY (site_id);


--
-- Name: site_onboarding site_onboarding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding
    ADD CONSTRAINT site_onboarding_pkey PRIMARY KEY (site_id);


--
-- Name: site_onboarding_screenshots site_onboarding_screenshots_site_id_s3_file_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_screenshots
    ADD CONSTRAINT site_onboarding_screenshots_site_id_s3_file_id_unique UNIQUE (site_id, s3_file_id);


--
-- Name: site_onboarding_upload site_onboarding_upload_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_upload
    ADD CONSTRAINT site_onboarding_upload_pkey UNIQUE (s3_file_id, site_id);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: site_publisher_ad_preferences site_publisher_ad_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_publisher_ad_preferences
    ADD CONSTRAINT site_publisher_ad_preferences_pkey PRIMARY KEY (id);


--
-- Name: site_publisher_ad_preferences site_publisher_ad_preferences_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_publisher_ad_preferences
    ADD CONSTRAINT site_publisher_ad_preferences_site_id_key UNIQUE (site_id);


--
-- Name: site_rev_share site_rev_share_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rev_share
    ADD CONSTRAINT site_rev_share_pkey PRIMARY KEY (id);


--
-- Name: site_rpm_guarantee site_rpm_guarantee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_guarantee
    ADD CONSTRAINT site_rpm_guarantee_pkey PRIMARY KEY (id);


--
-- Name: site_rpm_guarantee site_rpm_guarantee_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_guarantee
    ADD CONSTRAINT site_rpm_guarantee_site_id_key UNIQUE (site_id);


--
-- Name: site_rpm_input_after site_rpm_input_after_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_input_after
    ADD CONSTRAINT site_rpm_input_after_pkey PRIMARY KEY (id);


--
-- Name: site_rpm_input_before site_rpm_input_before_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_input_before
    ADD CONSTRAINT site_rpm_input_before_pkey PRIMARY KEY (id);


--
-- Name: site_rpm site_rpm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm
    ADD CONSTRAINT site_rpm_pkey PRIMARY KEY (id);


--
-- Name: site_rpm site_rpm_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm
    ADD CONSTRAINT site_rpm_site_id_key UNIQUE (site_id);


--
-- Name: site_social_media_info site_social_media_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_social_media_info
    ADD CONSTRAINT site_social_media_info_pkey PRIMARY KEY (id);


--
-- Name: site_style site_style_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_style
    ADD CONSTRAINT site_style_pkey PRIMARY KEY (id);


--
-- Name: site_style site_style_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_style
    ADD CONSTRAINT site_style_site_id_key UNIQUE (site_id);


--
-- Name: site_tracker site_tracker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_tracker
    ADD CONSTRAINT site_tracker_pkey PRIMARY KEY (id);


--
-- Name: site_user site_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user
    ADD CONSTRAINT site_user_pkey PRIMARY KEY (site_id, user_id);


--
-- Name: site_vertical site_vertical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_vertical
    ADD CONSTRAINT site_vertical_pkey PRIMARY KEY (site_id, vertical_id, sequence);


--
-- Name: site_video_ad_player site_video_ad_player_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_video_ad_player
    ADD CONSTRAINT site_video_ad_player_pkey PRIMARY KEY (id);


--
-- Name: site_video_sitemap site_video_sitemap_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_video_sitemap
    ADD CONSTRAINT site_video_sitemap_site_id_key UNIQUE (site_id);


--
-- Name: sites_tracker sites_tracker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites_tracker
    ADD CONSTRAINT sites_tracker_pkey PRIMARY KEY (site_id, site_tracker_id);


--
-- Name: test_site_earning_source test_site_earning_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_site_earning_source
    ADD CONSTRAINT test_site_earning_source_pkey PRIMARY KEY (date, site_id, ad_network_id, ad_unit, device, source, note);


--
-- Name: site_tracker tracker_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_tracker
    ADD CONSTRAINT tracker_name_unique UNIQUE (name);


--
-- Name: type_publisher_application_analytics_account_ga_type type_publisher_application_analytics_account_ga_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_publisher_application_analytics_account_ga_type
    ADD CONSTRAINT type_publisher_application_analytics_account_ga_type_pkey PRIMARY KEY (name);


--
-- Name: type_site_content_brief_language type_site_content_brief_language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_site_content_brief_language
    ADD CONSTRAINT type_site_content_brief_language_pkey PRIMARY KEY (name);


--
-- Name: type_site_content_brief_status type_site_content_brief_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_site_content_brief_status
    ADD CONSTRAINT type_site_content_brief_status_pkey PRIMARY KEY (name);


--
-- Name: type_site_content_brief_type type_site_content_brief_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_site_content_brief_type
    ADD CONSTRAINT type_site_content_brief_type_pkey PRIMARY KEY (name);


--
-- Name: type_site_keyword_recommendation_status type_site_keyword_recommendation_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_site_keyword_recommendation_status
    ADD CONSTRAINT type_site_keyword_recommendation_status_pkey PRIMARY KEY (name);


--
-- Name: type_site_keyword_recommendation_type type_site_keyword_recommendation_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_site_keyword_recommendation_type
    ADD CONSTRAINT type_site_keyword_recommendation_type_pkey PRIMARY KEY (name);


--
-- Name: user_contact user_contact_contact_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact
    ADD CONSTRAINT user_contact_contact_id_key UNIQUE (contact_id);


--
-- Name: user_contact_info user_contact_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact_info
    ADD CONSTRAINT user_contact_info_pkey PRIMARY KEY (id);


--
-- Name: user_contact_info user_contact_info_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact_info
    ADD CONSTRAINT user_contact_info_user_id_key UNIQUE (user_id);


--
-- Name: user_feedback_and_testing user_feedback_and_testing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback_and_testing
    ADD CONSTRAINT user_feedback_and_testing_pkey PRIMARY KEY (id);


--
-- Name: user_feedback_and_testing user_feedback_and_testing_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback_and_testing
    ADD CONSTRAINT user_feedback_and_testing_user_id_key UNIQUE (user_id);


--
-- Name: user_permission user_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (user_id, permission_id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: user_tc user_tc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tc
    ADD CONSTRAINT user_tc_pkey PRIMARY KEY (user_id, version, type);


--
-- Name: vertical vertical_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vertical
    ADD CONSTRAINT vertical_pkey PRIMARY KEY (id);


--
-- Name: video_sidebar_playlist_migration video_sidebar_playlist_migration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_sidebar_playlist_migration
    ADD CONSTRAINT video_sidebar_playlist_migration_pkey PRIMARY KEY (id);


--
-- Name: video_sidebar_playlist_migration video_sidebar_playlist_migration_site_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_sidebar_playlist_migration
    ADD CONSTRAINT video_sidebar_playlist_migration_site_id_key UNIQUE (site_id);


--
-- Name: zendesk_ticket_zendesk_macro zendesk_ticket_zendesk_macro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zendesk_ticket_zendesk_macro
    ADD CONSTRAINT zendesk_ticket_zendesk_macro_pkey PRIMARY KEY (id);


--
-- Name: zendesk_tickets zendesk_tickets_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zendesk_tickets
    ADD CONSTRAINT zendesk_tickets_id_unique UNIQUE (id);


--
-- Name: ad_unit_1_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ad_unit_1_name_idx ON public.ad_unit_1 USING btree (name);


--
-- Name: adthrive_dfp_earning_date_ad_network_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_date_ad_network_id_idx ON public.adthrive_dfp_earning USING btree (date, ad_network_id);


--
-- Name: adthrive_dfp_earning_date_ad_network_id_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_date_ad_network_id_site_id_idx ON public.adthrive_dfp_earning USING btree (date, ad_network_id, site_id);


--
-- Name: adthrive_dfp_earning_dimensio_date_site_id_ad_network_id_or_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimensio_date_site_id_ad_network_id_or_idx ON public.adthrive_dfp_earning_dimension USING btree (date, site_id, ad_network_id, order_name, dimension);


--
-- Name: adthrive_dfp_earning_dimension_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_date_index ON public.adthrive_dfp_earning_dimension USING btree (date);


--
-- Name: adthrive_dfp_earning_dimension_date_order_name_dimension_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_date_order_name_dimension_idx ON public.adthrive_dfp_earning_dimension USING btree (date, order_name, dimension);


--
-- Name: adthrive_dfp_earning_dimension_date_site_ad_network_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_date_site_ad_network_index ON public.adthrive_dfp_earning_dimension USING btree (date, site_id, ad_network_id);


--
-- Name: adthrive_dfp_earning_dimension_date_site_id_ad_network_id_metri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_date_site_id_ad_network_id_metri ON public.adthrive_dfp_earning_dimension USING btree (date, site_id, ad_network_id, gross_earnings, earnings, impressions, viewable_impressions);


--
-- Name: adthrive_dfp_earning_dimension_dimension_ad_network_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_dimension_ad_network_id_date_idx ON public.adthrive_dfp_earning_dimension USING btree (dimension, ad_network_id, date);


--
-- Name: adthrive_dfp_earning_dimension_dimension_ad_network_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_dimension_ad_network_id_idx ON public.adthrive_dfp_earning_dimension USING btree (dimension, ad_network_id);


--
-- Name: adthrive_dfp_earning_dimension_site_id_ad_network_id_metrics_in; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_site_id_ad_network_id_metrics_in ON public.adthrive_dfp_earning_dimension USING btree (site_id, ad_network_id, gross_earnings, earnings, impressions, viewable_impressions);


--
-- Name: adthrive_dfp_earning_dimension_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_dimension_site_id_index ON public.adthrive_dfp_earning_dimension USING btree (site_id);


--
-- Name: adthrive_dfp_earning_temp_date_ad_network_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_temp_date_ad_network_id_idx ON public.adthrive_dfp_earning_temp USING btree (date, ad_network_id);


--
-- Name: adthrive_dfp_earning_temp_date_ad_network_id_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_dfp_earning_temp_date_ad_network_id_site_id_idx ON public.adthrive_dfp_earning_temp USING btree (date, ad_network_id, site_id);


--
-- Name: adthrive_gam_earning_date_ad_network_id_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_gam_earning_date_ad_network_id_site_id_idx ON public.adthrive_gam_earning USING btree (date, ad_network_id, site_id);


--
-- Name: adthrive_gam_earning_date_ad_network_id_site_id_idx_old; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_gam_earning_date_ad_network_id_site_id_idx_old ON public.adthrive_gam_earning_old USING btree (date, ad_network_id, site_id);


--
-- Name: adthrive_gamlog_by_page_path_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_gamlog_by_page_path_date_idx ON public.adthrive_gamlog_by_page_path USING btree (date);


--
-- Name: adthrive_gamlog_by_page_path_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_gamlog_by_page_path_site_id_date_idx ON public.adthrive_gamlog_by_page_path USING btree (site_id, date);


--
-- Name: adthrive_gamlog_by_page_path_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adthrive_gamlog_by_page_path_site_id_idx ON public.adthrive_gamlog_by_page_path USING btree (site_id);


--
-- Name: alert_alert_distribution_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alert_alert_distribution_type_id_index ON public.alert USING btree (alert_distribution_type_id);


--
-- Name: alert_alert_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alert_alert_type_id_index ON public.alert USING btree (alert_type_id);


--
-- Name: application_analytic_account_country_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX application_analytic_account_country_date_index ON public.application_analytic_account_country USING btree (date);


--
-- Name: application_analytic_account_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX application_analytic_account_date_index ON public.application_analytic_account USING btree (date);


--
-- Name: application_analytic_account_device_category_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX application_analytic_account_device_category_date_index ON public.application_analytic_account_device_category USING btree (date);


--
-- Name: application_analytic_account_page_title_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX application_analytic_account_page_title_date_index ON public.application_analytic_account_page_title USING btree (date);


--
-- Name: application_analytic_account_source_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX application_analytic_account_source_date_index ON public.application_analytic_account_source USING btree (date);


--
-- Name: calendar_year_month_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_year_month_index ON public.calendar USING btree (year, month);


--
-- Name: entity_settings_key_value_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entity_settings_key_value_ix ON public.entity_settings USING btree (key, value);


--
-- Name: idx_request_log_date_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_request_log_date_status ON public.request_log USING btree (date, status_code);


--
-- Name: idx_request_log_status_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_request_log_status_code ON public.request_log USING btree (status_code) WHERE (status_code <> 200);


--
-- Name: manual_gamlog_page_path_20210526_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX manual_gamlog_page_path_20210526_date_idx ON public.manual_gamlog_page_path_20210526 USING btree (date);


--
-- Name: manual_gamlog_page_path_20210526_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX manual_gamlog_page_path_20210526_site_id_date_idx ON public.manual_gamlog_page_path_20210526 USING btree (site_id, date);


--
-- Name: manual_gamlog_page_path_20210526_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX manual_gamlog_page_path_20210526_site_id_idx ON public.manual_gamlog_page_path_20210526 USING btree (site_id);


--
-- Name: note_attachments_note_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX note_attachments_note_id_index ON public.note_attachments USING btree (note_id);


--
-- Name: publisher_application_analytics_profile_by_country_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publisher_application_analytics_profile_by_country_date_idx ON public.publisher_application_analytics_profile_by_country USING btree (date);


--
-- Name: publisher_application_analytics_profile_by_date_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publisher_application_analytics_profile_by_date_date_idx ON public.publisher_application_analytics_profile_by_date USING btree (date);


--
-- Name: publisher_application_analytics_profile_by_device_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publisher_application_analytics_profile_by_device_date_idx ON public.publisher_application_analytics_profile_by_device USING btree (date);


--
-- Name: publisher_application_analytics_profile_by_page_title_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publisher_application_analytics_profile_by_page_title_date_idx ON public.publisher_application_analytics_profile_by_page_title USING btree (date);


--
-- Name: publisher_application_analytics_profile_by_source_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publisher_application_analytics_profile_by_source_date_idx ON public.publisher_application_analytics_profile_by_source USING btree (date);


--
-- Name: publisher_application_public_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX publisher_application_public_id_idx ON public.publisher_application USING btree (public_id);


--
-- Name: s3_bucket_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX s3_bucket_name_index ON public.s3_bucket USING btree (name);


--
-- Name: site_ad_layout_site_id_ordering_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_ad_layout_site_id_ordering_idx ON public.site_ad_layout USING btree (site_id, ordering);


--
-- Name: site_add_user_codes_add_user_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_add_user_codes_add_user_code_index ON public.site_add_user_codes USING btree (add_user_code);


--
-- Name: site_add_user_codes_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_add_user_codes_site_id_index ON public.site_add_user_codes USING btree (site_id);


--
-- Name: site_alert_alert_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_alert_alert_id_index ON public.site_alert USING btree (alert_id);


--
-- Name: site_alert_closed_alert_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_alert_closed_alert_id_index ON public.site_alert_closed USING btree (alert_id);


--
-- Name: site_alert_closed_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_alert_closed_site_id_index ON public.site_alert_closed USING btree (site_id);


--
-- Name: site_alert_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_alert_site_id_index ON public.site_alert USING btree (site_id);


--
-- Name: site_analytic_account_country_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_country_date_index ON public.site_analytic_account_country USING btree (date);


--
-- Name: site_analytic_account_country_temp_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_country_temp_date_idx ON public.site_analytic_account_country_temp USING btree (date);


--
-- Name: site_analytic_account_device_category_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_device_category_date_index ON public.site_analytic_account_device_category USING btree (date);


--
-- Name: site_analytic_account_device_category_temp_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_device_category_temp_date_idx ON public.site_analytic_account_device_category_temp USING btree (date);


--
-- Name: site_analytic_account_page_title_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_page_title_date_index ON public.site_analytic_account_page_title USING btree (date);


--
-- Name: site_analytic_account_page_title_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_page_title_site_id_date_idx ON public.site_analytic_account_page_title USING btree (site_id, date);


--
-- Name: site_analytic_account_page_title_temp_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_page_title_temp_date_idx ON public.site_analytic_account_page_title_temp USING btree (date);


--
-- Name: site_analytic_account_page_title_temp_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_page_title_temp_site_id_date_idx ON public.site_analytic_account_page_title_temp USING btree (site_id, date);


--
-- Name: site_analytic_account_social_network_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_social_network_date_index ON public.site_analytic_account_social_network USING btree (date);


--
-- Name: site_analytic_account_social_network_temp_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_social_network_temp_date_idx ON public.site_analytic_account_social_network_temp USING btree (date);


--
-- Name: site_analytic_account_source_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_source_date_index ON public.site_analytic_account_source USING btree (date);


--
-- Name: site_analytic_account_source_temp_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_account_source_temp_date_idx ON public.site_analytic_account_source_temp USING btree (date);


--
-- Name: site_analytic_dimension_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_dimension_date_index ON public.site_analytic_account_dimension USING btree (date);


--
-- Name: site_analytic_dimension_site_id_date_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_analytic_dimension_site_id_date_name_index ON public.site_analytic_account_dimension USING btree (site_id, date, name);


--
-- Name: site_earning_analytics_by_page_path_202108; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_202108 ON public.site_earning_analytics_by_page_path USING btree (site_id, date) WHERE ((date >= '2021-08-01'::date) AND (date < '2021-09-01'::date));


--
-- Name: site_earning_analytics_by_page_path_202109; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_202109 ON public.site_earning_analytics_by_page_path USING btree (site_id, date) WHERE ((date >= '2021-09-01'::date) AND (date < '2021-10-01'::date));


--
-- Name: site_earning_analytics_by_page_path_202110; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_202110 ON public.site_earning_analytics_by_page_path USING btree (site_id, date) WHERE ((date >= '2021-10-01'::date) AND (date < '2021-11-01'::date));


--
-- Name: site_earning_analytics_by_page_path_202111; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_202111 ON public.site_earning_analytics_by_page_path USING btree (site_id, date) WHERE ((date >= '2021-11-01'::date) AND (date < '2021-12-01'::date));


--
-- Name: site_earning_analytics_by_page_path_date_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_date_site_id_idx ON public.site_earning_analytics_by_page_path USING btree (date, site_id);


--
-- Name: site_earning_analytics_by_page_path_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_site_id_date_idx ON public.site_earning_analytics_by_page_path USING btree (site_id, date);


--
-- Name: site_earning_analytics_by_page_path_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_site_id_idx ON public.site_earning_analytics_by_page_path USING btree (site_id);


--
-- Name: site_earning_analytics_by_page_path_temp_date_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_temp_date_site_id_idx ON public.site_earning_analytics_by_page_path_temp USING btree (date, site_id);


--
-- Name: site_earning_analytics_by_page_path_temp_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_temp_site_id_date_idx ON public.site_earning_analytics_by_page_path_temp USING btree (site_id, date);


--
-- Name: site_earning_analytics_by_page_path_temp_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_analytics_by_page_path_temp_site_id_idx ON public.site_earning_analytics_by_page_path_temp USING btree (site_id);


--
-- Name: site_earning_source_site_id_ad_network_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_source_site_id_ad_network_id_index ON public.site_earning_source USING btree (site_id, ad_network_id);


--
-- Name: site_earning_source_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_source_site_id_date_idx ON public.site_earning_source USING btree (site_id, date);


--
-- Name: site_earning_source_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_earning_source_site_id_index ON public.site_earning_source USING btree (site_id);


--
-- Name: site_ias_brand_safety_by_url_site_id_page_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_ias_brand_safety_by_url_site_id_page_path_idx ON public.site_ias_brand_safety_by_url USING btree (site_id, page_path);


--
-- Name: site_jw_analytic_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_jw_analytic_site_id_index ON public.site_jw_analytic USING btree (site_id);


--
-- Name: site_monthly_earning_site_id_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_monthly_earning_site_id_date_index ON public.site_monthly_earning USING btree (site_id, date);


--
-- Name: site_monthly_earning_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_monthly_earning_site_id_index ON public.site_monthly_earning USING btree (site_id);


--
-- Name: site_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_name_idx ON public.site USING btree (name);


--
-- Name: site_onboarding_ad_layout_ranking_pkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_onboarding_ad_layout_ranking_pkey ON public.site_onboarding_ad_layout_ranking USING btree (site_id);


--
-- Name: site_onboarding_ad_layout_ranking_site_id_rank_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX site_onboarding_ad_layout_ranking_site_id_rank_idx ON public.site_onboarding_ad_layout_ranking USING btree (site_id, rank);


--
-- Name: site_onboarding_screenshots_site_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_onboarding_screenshots_site_id_index ON public.site_onboarding_screenshots USING btree (site_id);


--
-- Name: snowflake_rpm_by_page_path_traf_site_id_traffic_source_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traf_site_id_traffic_source_date_idx ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, traffic_source, date);


--
-- Name: snowflake_rpm_by_page_path_traffic_202108; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202108 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2021-08-01'::date) AND (date < '2021-09-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202109; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202109 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2021-09-01'::date) AND (date < '2021-10-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202110; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202110 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2021-10-01'::date) AND (date < '2021-11-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202111; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202111 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2021-11-01'::date) AND (date < '2021-12-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202112; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202112 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2021-12-01'::date) AND (date < '2022-01-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202201; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202201 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-01-01'::date) AND (date < '2022-02-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202202; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202202 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-02-01'::date) AND (date < '2022-03-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202203; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202203 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-03-01'::date) AND (date < '2022-04-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202204; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202204 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-04-01'::date) AND (date < '2022-05-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202205; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202205 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-05-01'::date) AND (date < '2022-06-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202206; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202206 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-06-01'::date) AND (date < '2022-07-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202207; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202207 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-07-01'::date) AND (date < '2022-08-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202208; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202208 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-08-01'::date) AND (date < '2022-09-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202209; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202209 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-09-01'::date) AND (date < '2022-10-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202210; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202210 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-10-01'::date) AND (date < '2022-11-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202211; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202211 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-11-01'::date) AND (date < '2022-12-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_202212; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_202212 ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date) WHERE ((date >= '2022-12-01'::date) AND (date < '2023-01-01'::date));


--
-- Name: snowflake_rpm_by_page_path_traffic_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snowflake_rpm_by_page_path_traffic_site_id_date_idx ON public.snowflake_rpm_by_page_path_traffic USING btree (site_id, date);


--
-- Name: temp_dfp_order_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX temp_dfp_order_name_idx ON public.temp_dfp_order USING btree (name);


--
-- Name: test_site_earning_source_site_id_ad_network_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_site_earning_source_site_id_ad_network_id_idx ON public.test_site_earning_source USING btree (site_id, ad_network_id);


--
-- Name: test_site_earning_source_site_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_site_earning_source_site_id_date_idx ON public.test_site_earning_source USING btree (site_id, date);


--
-- Name: test_site_earning_source_site_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX test_site_earning_source_site_id_idx ON public.test_site_earning_source USING btree (site_id);


--
-- Name: user_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_email_idx ON public."user" USING btree (email);


--
-- Name: user_role_user_id_role_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_role_user_id_role_id_idx ON public.user_role USING btree (user_id, role_id) WHERE (site_id IS NULL);


--
-- Name: user_role_user_id_site_id_role_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_role_user_id_site_id_role_id_idx ON public.user_role USING btree (user_id, site_id, role_id) WHERE (site_id IS NOT NULL);


--
-- Name: user_roles_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_roles_name_idx ON public.user_roles USING btree (name);


--
-- Name: user_settings_user_id_key_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_settings_user_id_key_unique_idx ON public.user_settings USING btree (user_id, key);


--
-- Name: site_ad_layout on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_update BEFORE UPDATE ON public.site_ad_layout FOR EACH ROW EXECUTE PROCEDURE public.on_update();


--
-- Name: site_video_ad_player on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_update BEFORE UPDATE ON public.site_video_ad_player FOR EACH ROW EXECUTE PROCEDURE public.on_update();


--
-- Name: account_organization account_organization_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_organization
    ADD CONSTRAINT account_organization_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id);


--
-- Name: ad_code_config ad_code_config_uploaded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_code_config
    ADD CONSTRAINT ad_code_config_uploaded_by_user_id_fkey FOREIGN KEY (uploaded_by_user_id) REFERENCES public."user"(id);


--
-- Name: ad_location_ad_size ad_location_ad_size_ad_location_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_location_ad_size
    ADD CONSTRAINT ad_location_ad_size_ad_location_id_foreign FOREIGN KEY (ad_location_id) REFERENCES public.ad_location(id);


--
-- Name: ad_location_ad_size ad_location_ad_size_ad_size_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_location_ad_size
    ADD CONSTRAINT ad_location_ad_size_ad_size_id_foreign FOREIGN KEY (ad_size_id) REFERENCES public.ad_size(id);


--
-- Name: default_ad_layout ad_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_ad_layout
    ADD CONSTRAINT ad_location_id_fkey FOREIGN KEY (ad_location_id) REFERENCES public.ad_location(id);


--
-- Name: ad_network_device ad_network_device_ad_network_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ad_network_device
    ADD CONSTRAINT ad_network_device_ad_network_id_foreign FOREIGN KEY (ad_network_id) REFERENCES public.data_source(id);


--
-- Name: adthrive_dfp_earning adthrive_dfp_earning_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning
    ADD CONSTRAINT adthrive_dfp_earning_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: adthrive_dfp_earning_dimension adthrive_dfp_earning_dimension_ad_network_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning_dimension
    ADD CONSTRAINT adthrive_dfp_earning_dimension_ad_network_id_foreign FOREIGN KEY (ad_network_id) REFERENCES public.data_source(id);


--
-- Name: adthrive_dfp_earning_dimension adthrive_dfp_earning_dimension_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning_dimension
    ADD CONSTRAINT adthrive_dfp_earning_dimension_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: adthrive_dfp_earning_dimension adthrive_dfp_earning_dimension_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_earning_dimension
    ADD CONSTRAINT adthrive_dfp_earning_dimension_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: adthrive_dfp_impression_device_dimension adthrive_dfp_impression_device_dimension_ad_network_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_impression_device_dimension
    ADD CONSTRAINT adthrive_dfp_impression_device_dimension_ad_network_id_foreign FOREIGN KEY (ad_network_id) REFERENCES public.data_source(id);


--
-- Name: adthrive_dfp_impression_device_dimension adthrive_dfp_impression_device_dimension_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_impression_device_dimension
    ADD CONSTRAINT adthrive_dfp_impression_device_dimension_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: adthrive_dfp_impression_device_dimension adthrive_dfp_impression_device_dimension_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_dfp_impression_device_dimension
    ADD CONSTRAINT adthrive_dfp_impression_device_dimension_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: adthrive_gum_gum_earning adthrive_gum_gum_earning_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gum_gum_earning
    ADD CONSTRAINT adthrive_gum_gum_earning_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: adthrive_gum_gum_earning adthrive_gum_gum_earning_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_gum_gum_earning
    ADD CONSTRAINT adthrive_gum_gum_earning_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: adthrive_sekindo_earning adthrive_sekindo_earning_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_sekindo_earning
    ADD CONSTRAINT adthrive_sekindo_earning_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: adthrive_sekindo_earning adthrive_sekindo_earning_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adthrive_sekindo_earning
    ADD CONSTRAINT adthrive_sekindo_earning_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: alert alert_alert_distribution_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert
    ADD CONSTRAINT alert_alert_distribution_type_id_foreign FOREIGN KEY (alert_distribution_type_id) REFERENCES public.alert_distribution_type(id);


--
-- Name: alert alert_alert_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert
    ADD CONSTRAINT alert_alert_type_id_foreign FOREIGN KEY (alert_type_id) REFERENCES public.alert_type(id);


--
-- Name: application_account application_account_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_account
    ADD CONSTRAINT application_account_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: application_analytic_account application_analytic_account_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account
    ADD CONSTRAINT application_analytic_account_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: application_analytic_account_country application_analytic_account_country_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_country
    ADD CONSTRAINT application_analytic_account_country_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: application_analytic_account_country application_analytic_account_country_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_country
    ADD CONSTRAINT application_analytic_account_country_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: application_analytic_account application_analytic_account_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account
    ADD CONSTRAINT application_analytic_account_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: application_analytic_account_device_category application_analytic_account_device_category_application_id_for; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_device_category
    ADD CONSTRAINT application_analytic_account_device_category_application_id_for FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: application_analytic_account_device_category application_analytic_account_device_category_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_device_category
    ADD CONSTRAINT application_analytic_account_device_category_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: application_analytic_account_page_title application_analytic_account_page_title_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_page_title
    ADD CONSTRAINT application_analytic_account_page_title_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: application_analytic_account_page_title application_analytic_account_page_title_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_page_title
    ADD CONSTRAINT application_analytic_account_page_title_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: application_analytic_account_source application_analytic_account_source_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_source
    ADD CONSTRAINT application_analytic_account_source_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.application(id);


--
-- Name: application_analytic_account_source application_analytic_account_source_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_analytic_account_source
    ADD CONSTRAINT application_analytic_account_source_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: application application_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: brief_performance_summary brief_performance_summary_brief_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brief_performance_summary
    ADD CONSTRAINT brief_performance_summary_brief_id_fkey FOREIGN KEY (brief_id) REFERENCES public.site_content_brief(id);


--
-- Name: brief_performance_summary brief_performance_summary_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brief_performance_summary
    ADD CONSTRAINT brief_performance_summary_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: change_history change_history_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_history
    ADD CONSTRAINT change_history_user_id_foreign FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: content_optimization_algorithm content_optimization_algorithm_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_optimization_algorithm
    ADD CONSTRAINT content_optimization_algorithm_created_by_fkey FOREIGN KEY (created_by) REFERENCES public."user"(id);


--
-- Name: content_optimization_onboarding content_optimization_onboarding_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_optimization_onboarding
    ADD CONSTRAINT content_optimization_onboarding_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: dropped_reason dropped_reason_dropped_reason_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dropped_reason
    ADD CONSTRAINT dropped_reason_dropped_reason_category_id_foreign FOREIGN KEY (dropped_reason_category_id) REFERENCES public.dropped_reason_category(id);


--
-- Name: job job_end_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_end_date_foreign FOREIGN KEY (end_date) REFERENCES public.calendar(id);


--
-- Name: job_issue job_issue_end_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_issue
    ADD CONSTRAINT job_issue_end_date_foreign FOREIGN KEY (end_date) REFERENCES public.calendar(id);


--
-- Name: job_issue job_issue_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_issue
    ADD CONSTRAINT job_issue_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id);


--
-- Name: job_issue job_issue_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_issue
    ADD CONSTRAINT job_issue_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: job_issue job_issue_start_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_issue
    ADD CONSTRAINT job_issue_start_date_foreign FOREIGN KEY (start_date) REFERENCES public.calendar(id);


--
-- Name: job job_start_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_start_date_foreign FOREIGN KEY (start_date) REFERENCES public.calendar(id);


--
-- Name: log log_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: mcm_migration_child_publisher mcm_migration_child_publisher_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_child_publisher
    ADD CONSTRAINT mcm_migration_child_publisher_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: mcm_migration_reminder mcm_migration_reminder_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_reminder
    ADD CONSTRAINT mcm_migration_reminder_alert_id_fkey FOREIGN KEY (alert_id) REFERENCES public.alert(id);


--
-- Name: mcm_migration_reminder mcm_migration_reminder_mcm_migration_child_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_reminder
    ADD CONSTRAINT mcm_migration_reminder_mcm_migration_child_publisher_id_fkey FOREIGN KEY (mcm_migration_child_publisher_id) REFERENCES public.mcm_migration_child_publisher(id);


--
-- Name: mcm_migration_site mcm_migration_site_mcm_migration_child_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_site
    ADD CONSTRAINT mcm_migration_site_mcm_migration_child_publisher_id_fkey FOREIGN KEY (mcm_migration_child_publisher_id) REFERENCES public.mcm_migration_child_publisher(id);


--
-- Name: mcm_migration_site mcm_migration_site_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mcm_migration_site
    ADD CONSTRAINT mcm_migration_site_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: note_attachments note_attachments_note_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_attachments
    ADD CONSTRAINT note_attachments_note_id_foreign FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: note_attachments note_attachments_s3_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_attachments
    ADD CONSTRAINT note_attachments_s3_file_id_foreign FOREIGN KEY (s3_file_id) REFERENCES public.s3_file(id);


--
-- Name: notes notes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public."user"(id);


--
-- Name: notes notes_last_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_last_updated_by_foreign FOREIGN KEY (last_updated_by) REFERENCES public."user"(id);


--
-- Name: notes notes_note_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_note_status_id_fkey FOREIGN KEY (note_status_id) REFERENCES public.note_status(id);


--
-- Name: notes notes_note_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_note_type_id_foreign FOREIGN KEY (note_type_id) REFERENCES public.note_types(id);


--
-- Name: org_demographic_info_migration_staging org_demographic_info_migration_staging_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_demographic_info_migration_staging
    ADD CONSTRAINT org_demographic_info_migration_staging_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: org_demographic_info_migration_staging org_demographic_info_migration_staging_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_demographic_info_migration_staging
    ADD CONSTRAINT org_demographic_info_migration_staging_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: org_demographic_info_migration_staging org_demographic_info_migration_staging_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_demographic_info_migration_staging
    ADD CONSTRAINT org_demographic_info_migration_staging_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: organization organization_account_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_account_manager_id_fkey FOREIGN KEY (account_manager_id) REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: organization_demographic_info organization_demographic_info_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_demographic_info
    ADD CONSTRAINT organization_demographic_info_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id);


--
-- Name: organization organization_mcm_child_publisher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_mcm_child_publisher_id_fkey FOREIGN KEY (mcm_child_publisher_id) REFERENCES public.mcm_child_publisher(id);


--
-- Name: organization organization_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public."user"(id);


--
-- Name: organization organization_primary_contact_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_primary_contact_user_id_fkey FOREIGN KEY (primary_contact_user_id) REFERENCES public."user"(id);


--
-- Name: organization_user organization_user_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id);


--
-- Name: organization_user organization_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_user
    ADD CONSTRAINT organization_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: primis_earning primis_earning_date_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.primis_earning
    ADD CONSTRAINT primis_earning_date_fkey FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: publisher_application_ad_network publisher_application_ad_network_data_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_ad_network
    ADD CONSTRAINT publisher_application_ad_network_data_source_id_foreign FOREIGN KEY (data_source_id) REFERENCES public.data_source(id);


--
-- Name: publisher_application_ad_network publisher_application_ad_network_publisher_application_id_forei; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_ad_network
    ADD CONSTRAINT publisher_application_ad_network_publisher_application_id_forei FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_analytics_account publisher_application_analytics_account_ga_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_account
    ADD CONSTRAINT publisher_application_analytics_account_ga_type_fkey FOREIGN KEY (ga_type) REFERENCES public.type_publisher_application_analytics_account_ga_type(name);


--
-- Name: publisher_application_analytics_account publisher_application_analytics_account_publisher_application_i; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_account
    ADD CONSTRAINT publisher_application_analytics_account_publisher_application_i FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_analytics_profile_by_country publisher_application_analytics_profile_by_country_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_country
    ADD CONSTRAINT publisher_application_analytics_profile_by_country_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: publisher_application_analytics_profile_by_country publisher_application_analytics_profile_by_country_publisher_ap; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_country
    ADD CONSTRAINT publisher_application_analytics_profile_by_country_publisher_ap FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_analytics_profile_by_date publisher_application_analytics_profile_by_date_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_date
    ADD CONSTRAINT publisher_application_analytics_profile_by_date_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: publisher_application_analytics_profile_by_date publisher_application_analytics_profile_by_date_publisher_appli; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_date
    ADD CONSTRAINT publisher_application_analytics_profile_by_date_publisher_appli FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_analytics_profile_by_device publisher_application_analytics_profile_by_device_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_device
    ADD CONSTRAINT publisher_application_analytics_profile_by_device_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: publisher_application_analytics_profile_by_device publisher_application_analytics_profile_by_device_publisher_app; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_device
    ADD CONSTRAINT publisher_application_analytics_profile_by_device_publisher_app FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_analytics_profile_by_page_title publisher_application_analytics_profile_by_page_title_date_fore; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_page_title
    ADD CONSTRAINT publisher_application_analytics_profile_by_page_title_date_fore FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: publisher_application_analytics_profile_by_page_title publisher_application_analytics_profile_by_page_title_publisher; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_page_title
    ADD CONSTRAINT publisher_application_analytics_profile_by_page_title_publisher FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_analytics_profile_by_source publisher_application_analytics_profile_by_source_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_source
    ADD CONSTRAINT publisher_application_analytics_profile_by_source_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: publisher_application_analytics_profile_by_source publisher_application_analytics_profile_by_source_publisher_app; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_analytics_profile_by_source
    ADD CONSTRAINT publisher_application_analytics_profile_by_source_publisher_app FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application publisher_application_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application
    ADD CONSTRAINT publisher_application_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id);


--
-- Name: publisher_application publisher_application_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application
    ADD CONSTRAINT publisher_application_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: publisher_application_vertical publisher_application_vertical_publisher_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_vertical
    ADD CONSTRAINT publisher_application_vertical_publisher_application_id_foreign FOREIGN KEY (publisher_application_id) REFERENCES public.publisher_application(id);


--
-- Name: publisher_application_vertical publisher_application_vertical_vertical_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publisher_application_vertical
    ADD CONSTRAINT publisher_application_vertical_vertical_id_foreign FOREIGN KEY (vertical_id) REFERENCES public.vertical(id);


--
-- Name: request_log_old request_log_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_log_old
    ADD CONSTRAINT request_log_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: role_permission role_permission_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permission(id);


--
-- Name: role_permission role_permission_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- Name: role_permission role_permission_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.role(id) MATCH FULL;


--
-- Name: s3_file s3_file_bucket_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.s3_file
    ADD CONSTRAINT s3_file_bucket_id_foreign FOREIGN KEY (bucket_id) REFERENCES public.s3_bucket(id);


--
-- Name: site_ad_layout site_ad_layout_ad_location_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_layout
    ADD CONSTRAINT site_ad_layout_ad_location_id_foreign FOREIGN KEY (ad_location_id) REFERENCES public.ad_location(id);


--
-- Name: site_ad_layout_meta site_ad_layout_meta_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_layout_meta
    ADD CONSTRAINT site_ad_layout_meta_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_ad_layout site_ad_layout_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_layout
    ADD CONSTRAINT site_ad_layout_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site site_ad_manager_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_ad_manager_foreign FOREIGN KEY (ad_manager) REFERENCES public."user"(id);


--
-- Name: site_ad_network_earning site_ad_network_earning_ad_network_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_network_earning
    ADD CONSTRAINT site_ad_network_earning_ad_network_id_foreign FOREIGN KEY (ad_network_id) REFERENCES public.data_source(id);


--
-- Name: site_ad_network_earning site_ad_network_earning_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_network_earning
    ADD CONSTRAINT site_ad_network_earning_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_ad_sense_earning site_ad_sense_earning_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_sense_earning
    ADD CONSTRAINT site_ad_sense_earning_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_ad_sense_earning_domain site_ad_sense_earning_domain_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_sense_earning_domain
    ADD CONSTRAINT site_ad_sense_earning_domain_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_ad_sense_earning_domain site_ad_sense_earning_domain_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_sense_earning_domain
    ADD CONSTRAINT site_ad_sense_earning_domain_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_ad_sense_earning site_ad_sense_earning_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_ad_sense_earning
    ADD CONSTRAINT site_ad_sense_earning_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_alert site_alert_alert_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert
    ADD CONSTRAINT site_alert_alert_id_foreign FOREIGN KEY (alert_id) REFERENCES public.alert(id);


--
-- Name: site_alert_closed site_alert_closed_alert_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert_closed
    ADD CONSTRAINT site_alert_closed_alert_id_foreign FOREIGN KEY (alert_id) REFERENCES public.alert(id);


--
-- Name: site_alert_closed site_alert_closed_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert_closed
    ADD CONSTRAINT site_alert_closed_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_alert site_alert_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_alert
    ADD CONSTRAINT site_alert_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account_country site_analytic_account_country_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_country
    ADD CONSTRAINT site_analytic_account_country_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_country site_analytic_account_country_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_country
    ADD CONSTRAINT site_analytic_account_country_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account site_analytic_account_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account
    ADD CONSTRAINT site_analytic_account_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_device_category site_analytic_account_device_category_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_device_category
    ADD CONSTRAINT site_analytic_account_device_category_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_device_category site_analytic_account_device_category_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_device_category
    ADD CONSTRAINT site_analytic_account_device_category_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account_dimension site_analytic_account_dimension_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_dimension
    ADD CONSTRAINT site_analytic_account_dimension_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_dimension site_analytic_account_dimension_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_dimension
    ADD CONSTRAINT site_analytic_account_dimension_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account_page_title site_analytic_account_page_title_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_page_title
    ADD CONSTRAINT site_analytic_account_page_title_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_page_title site_analytic_account_page_title_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_page_title
    ADD CONSTRAINT site_analytic_account_page_title_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account site_analytic_account_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account
    ADD CONSTRAINT site_analytic_account_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account_social_network site_analytic_account_social_network_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_social_network
    ADD CONSTRAINT site_analytic_account_social_network_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_social_network site_analytic_account_social_network_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_social_network
    ADD CONSTRAINT site_analytic_account_social_network_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account_source site_analytic_account_source_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_source
    ADD CONSTRAINT site_analytic_account_source_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_source site_analytic_account_source_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_source
    ADD CONSTRAINT site_analytic_account_source_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_analytic_account_speed site_analytic_account_speed_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_speed
    ADD CONSTRAINT site_analytic_account_speed_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_analytic_account_speed site_analytic_account_speed_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_analytic_account_speed
    ADD CONSTRAINT site_analytic_account_speed_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_authorization site_authorization_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_authorization
    ADD CONSTRAINT site_authorization_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_cms site_cms_cms_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_cms
    ADD CONSTRAINT site_cms_cms_id_foreign FOREIGN KEY (cms_id) REFERENCES public.cms(id);


--
-- Name: site_cms site_cms_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_cms
    ADD CONSTRAINT site_cms_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_competitors site_competitors_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_competitors
    ADD CONSTRAINT site_competitors_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_content_brief site_content_brief_language_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content_brief
    ADD CONSTRAINT site_content_brief_language_fkey FOREIGN KEY (language) REFERENCES public.type_site_content_brief_language(name);


--
-- Name: site_content_brief site_content_brief_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content_brief
    ADD CONSTRAINT site_content_brief_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_content_brief site_content_brief_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content_brief
    ADD CONSTRAINT site_content_brief_status_fkey FOREIGN KEY (status) REFERENCES public.type_site_content_brief_status(name);


--
-- Name: site_content_brief site_content_brief_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_content_brief
    ADD CONSTRAINT site_content_brief_type_fkey FOREIGN KEY (type) REFERENCES public.type_site_content_brief_type(name);


--
-- Name: site site_dashboard_start_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_dashboard_start_date_foreign FOREIGN KEY (dashboard_start_date) REFERENCES public.calendar(id);


--
-- Name: site_data_source site_data_source_data_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_data_source
    ADD CONSTRAINT site_data_source_data_source_id_foreign FOREIGN KEY (data_source_id) REFERENCES public.data_source(id);


--
-- Name: site_data_source site_data_source_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_data_source
    ADD CONSTRAINT site_data_source_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_demographic_info site_demographic_info_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_demographic_info
    ADD CONSTRAINT site_demographic_info_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site site_dropped_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_dropped_reason_id_foreign FOREIGN KEY (dropped_reason_id) REFERENCES public.dropped_reason(id);


--
-- Name: site_earning_source site_earning_source_ad_network_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_earning_source
    ADD CONSTRAINT site_earning_source_ad_network_id_foreign FOREIGN KEY (ad_network_id) REFERENCES public.data_source(id) NOT VALID;


--
-- Name: site_earning_source site_earning_source_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_earning_source
    ADD CONSTRAINT site_earning_source_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id) NOT VALID;


--
-- Name: site_earning_source site_earning_source_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_earning_source
    ADD CONSTRAINT site_earning_source_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id) NOT VALID;


--
-- Name: site_gsc_auth site_gsc_auth_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_gsc_auth
    ADD CONSTRAINT site_gsc_auth_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_guided_action site_guided_action_guided_action_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_guided_action
    ADD CONSTRAINT site_guided_action_guided_action_name_fkey FOREIGN KEY (guided_action_name) REFERENCES public.guided_action(name);


--
-- Name: site_guided_action site_guided_action_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_guided_action
    ADD CONSTRAINT site_guided_action_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site site_install_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_install_date_foreign FOREIGN KEY (install_date) REFERENCES public.calendar(id);


--
-- Name: site_jw_player site_jw_player_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_jw_player
    ADD CONSTRAINT site_jw_player_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_jw_video site_jw_video_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_jw_video
    ADD CONSTRAINT site_jw_video_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_keyword_recommendation site_keyword_recommendation_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_keyword_recommendation
    ADD CONSTRAINT site_keyword_recommendation_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_keyword_recommendation site_keyword_recommendation_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_keyword_recommendation
    ADD CONSTRAINT site_keyword_recommendation_status_fkey FOREIGN KEY (status) REFERENCES public.type_site_keyword_recommendation_status(name);


--
-- Name: site_keyword_recommendation site_keyword_recommendation_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_keyword_recommendation
    ADD CONSTRAINT site_keyword_recommendation_type_fkey FOREIGN KEY (type) REFERENCES public.type_site_keyword_recommendation_type(name);


--
-- Name: site_monthly_analytic site_monthly_analytic_effective_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_analytic
    ADD CONSTRAINT site_monthly_analytic_effective_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_monthly_earning site_monthly_earning_ad_network_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_earning
    ADD CONSTRAINT site_monthly_earning_ad_network_id_foreign FOREIGN KEY (ad_network_id) REFERENCES public.data_source(id);


--
-- Name: site_monthly_earning site_monthly_earning_effective_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_earning
    ADD CONSTRAINT site_monthly_earning_effective_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_monthly_metric site_monthly_metric_effective_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_monthly_metric
    ADD CONSTRAINT site_monthly_metric_effective_date_foreign FOREIGN KEY (date) REFERENCES public.calendar(id);


--
-- Name: site_offboarding site_offboarding_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_offboarding
    ADD CONSTRAINT site_offboarding_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_onboarding_ad_layout_ranking site_onboarding_ad_layout_ranking_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_ad_layout_ranking
    ADD CONSTRAINT site_onboarding_ad_layout_ranking_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_onboarding_screenshots site_onboarding_screenshots_s3_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_screenshots
    ADD CONSTRAINT site_onboarding_screenshots_s3_file_id_foreign FOREIGN KEY (s3_file_id) REFERENCES public.s3_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: site_onboarding_screenshots site_onboarding_screenshots_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_screenshots
    ADD CONSTRAINT site_onboarding_screenshots_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_onboarding site_onboarding_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding
    ADD CONSTRAINT site_onboarding_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_onboarding_zendesk site_onboarding_zendesk_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_onboarding_zendesk
    ADD CONSTRAINT site_onboarding_zendesk_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_publisher_ad_preferences site_publisher_ad_preferences_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_publisher_ad_preferences
    ADD CONSTRAINT site_publisher_ad_preferences_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_rev_share site_rev_share_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rev_share
    ADD CONSTRAINT site_rev_share_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_rev_share site_rev_share_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rev_share
    ADD CONSTRAINT site_rev_share_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: site_rpm_guarantee site_rpm_guarantee_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_guarantee
    ADD CONSTRAINT site_rpm_guarantee_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_rpm_input_after site_rpm_input_after_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_input_after
    ADD CONSTRAINT site_rpm_input_after_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_rpm_input_before site_rpm_input_before_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm_input_before
    ADD CONSTRAINT site_rpm_input_before_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_rpm site_rpm_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_rpm
    ADD CONSTRAINT site_rpm_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_social_media_info site_social_media_info_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_social_media_info
    ADD CONSTRAINT site_social_media_info_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site site_start_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_start_date_foreign FOREIGN KEY (start_date) REFERENCES public.calendar(id);


--
-- Name: site_style site_style_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_style
    ADD CONSTRAINT site_style_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_tracker site_tracker_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_tracker
    ADD CONSTRAINT site_tracker_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: site_user site_user_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user
    ADD CONSTRAINT site_user_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_user site_user_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_user
    ADD CONSTRAINT site_user_user_id_foreign FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: site site_velocity_start_date_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_velocity_start_date_foreign FOREIGN KEY (velocity_start_date) REFERENCES public.calendar(id);


--
-- Name: site_vertical site_vertical_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_vertical
    ADD CONSTRAINT site_vertical_site_id_foreign FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_vertical site_vertical_vertical_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_vertical
    ADD CONSTRAINT site_vertical_vertical_id_foreign FOREIGN KEY (vertical_id) REFERENCES public.vertical(id);


--
-- Name: site_video_ad_player site_video_ad_player_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_video_ad_player
    ADD CONSTRAINT site_video_ad_player_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: site_video_sitemap site_video_sitemap_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_video_sitemap
    ADD CONSTRAINT site_video_sitemap_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: sites_tracker sites_tracker_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites_tracker
    ADD CONSTRAINT sites_tracker_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: sites_tracker sites_tracker_site_tracker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites_tracker
    ADD CONSTRAINT sites_tracker_site_tracker_id_fkey FOREIGN KEY (site_tracker_id) REFERENCES public.site_tracker(id);


--
-- Name: user_contact_info user_contact_info_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact_info
    ADD CONSTRAINT user_contact_info_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_contact user_contact_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_contact
    ADD CONSTRAINT user_contact_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_feedback_and_testing user_feedback_and_testing_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback_and_testing
    ADD CONSTRAINT user_feedback_and_testing_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_permission user_permission_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permission(id);


--
-- Name: user_permission user_permission_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_role user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- Name: user_role user_role_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: user_role user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_settings user_settings_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_user_id_foreign FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_tc user_tc_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tc
    ADD CONSTRAINT user_tc_user_id_foreign FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user user_user_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_user_role_id_foreign FOREIGN KEY (user_role_id) REFERENCES public.user_roles(id);


--
-- Name: video_sidebar_playlist_migration video_sidebar_playlist_migration_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_sidebar_playlist_migration
    ADD CONSTRAINT video_sidebar_playlist_migration_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id);


--
-- Name: zendesk_ticket_zendesk_macro zendesk_ticket_zendesk_macro_zendesk_ticket_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zendesk_ticket_zendesk_macro
    ADD CONSTRAINT zendesk_ticket_zendesk_macro_zendesk_ticket_id_foreign FOREIGN KEY (zendesk_ticket_id) REFERENCES public.zendesk_tickets(id);


--
-- PostgreSQL database dump complete
--

