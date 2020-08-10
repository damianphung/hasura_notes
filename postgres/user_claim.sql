CREATE TABLE user_claim (
  id      uuid NOT NULL DEFAULT uuid_generate_v1mc(),
  user_id uuid NOT NULL,
  type    character varying(256),
  value   character varying(4000),
  -- Keys
  CONSTRAINT user_claim_pkey PRIMARY KEY (id),
  CONSTRAINT user_claim_user_account_fkey FOREIGN KEY (user_id)
      REFERENCES user_account (id) MATCH SIMPLE
      ON DELETE CASCADE ON UPDATE CASCADE
);