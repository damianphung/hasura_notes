CREATE TABLE user_profile (
  user_id      uuid NOT NULL,
  display_name character varying(100),
  picture      character varying(256),
  gender       character varying(50),
  location     character varying(100),
  website      character varying(256),
  created_at   timestamp without time zone DEFAULT timezone('utc'::text, now()),
  updated_at   timestamp without time zone DEFAULT timezone('utc'::text, now()),
  -- Keys
  CONSTRAINT user_profile_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_profile_user_account_fkey FOREIGN KEY (user_id)
      REFERENCES user_account (id) MATCH SIMPLE
      ON DELETE CASCADE ON UPDATE CASCADE
);