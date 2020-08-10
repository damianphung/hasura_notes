CREATE TABLE user_login (
  name    character varying(50),
  key     character varying(100),
  user_id uuid NOT NULL,
  -- Keys
  CONSTRAINT user_login_pkey PRIMARY KEY (name, key),
  CONSTRAINT user_login_user_account_fkey FOREIGN KEY (user_id)
      REFERENCES user_account (id) MATCH SIMPLE
      ON DELETE CASCADE ON UPDATE CASCADE
);