# Hasura Notes
[See this course intro link](https://hasura.io/learn/graphql/hasura/introduction/)

Worth reading:

https://medium.com/firebase-developers/how-we-moved-6-million-users-from-auth0-to-firebase-d46fd13cfda8

## Authentication notes

[See this hasura link](https://hasura.io/learn/graphql/hasura/authentication/1-create-auth0-app/)
Integrating Auth0 with Hasura

We signed up for an Auth0 account.
Auth0 provides a free tier of 7000 users.
You need to create an ```Application``` (i.e called HasuraAuth) and note the:
- Domain
- Client ID
- Allowed Callback URL

By providing ```Rules``` you can configure Auth0 to execute small javascript snippets as part of your authentication pipeline such as:
- Adding a custom namespace in the JWT returned by Auth0
- Verify that the users in Auth0 to be in sync with our postgres database

Testing a login request with Auth0, and then logging in gave us a response to the callback URL we provided with the access token we need to authenticate the user.


## Hasura Actions
### GraphQL schema
Recall that a GraphQL schema is simply a declaration of data that a client can request and what a server can provide back.

The underlying implementation of the data retrieval lies in the ```resolver``` function. 

When we define the PostgreSQL schema; Hasura will generate the graphQL endpoints and schema from this PG schema.

If however we want to add a webhook as part of a custom ```resolver``` function, we will need to add a new GraphQL endpoint, along with the custom ```resolver``` function that calls the webhook.

We create a new GraphQL endpoint with the type definitions of Auth0.
#### Flow steps
- This is the entrypoint of the calling client where we login.
- We need to add a Authorization header with the Bearer token from logging in to Auth0 using this format https://auth0-domain.auth0.com/login?client=client_id&protocol=oauth2&response_type=token%20id_token&redirect_uri=callback_uri&scope=openid%20profile
- This request is then forwarded to a web service that we used to build on [this awesome tool called glitch](www.glitch.com).
- The web service extracts the user_uid from the token.
- Now we send a auth0 request for the user profile using the user_uid, using the Auth0 Token from the application (admin level access).
- This returns a JSON containing email and picture fields.

Difference between Webhook and remote GraphQL server
#### Webhook 
- we define the graphql type and query. 
- we provide the webhook url that the request will be forwarded to. 
- run ```flow steps```

#### GraphQL remote 
we define a graphql server using apollo.
- define the graphql types.
- define the graphql query
- define the resolver to run ```flow steps```


## Event webhooks

We were able to integrate event webhooks in Hasura and use that to trigger the SendGrid API to send a email to notify us a new email signed up.

### SendGrid
Create SendGrid account 
- Select ```Email API``` and then ```Integration Guide```
- Here you register a new API key and associate that with SendGrid SMTP servers.
- Copy the user/pass/smtp host 

### Create web service that will process the event trigger request
We shall use [glitch](www.glitch.com) to quickly create a web service that will
- Configure the SendGrid API based on above ```SendGrid``` details
- Listen for ```/send-email``` POST sign up request
- Extract the name of user in the request
- Send to the SendGrid server with the content we want to deliver. 

### Create event webhook in Hasura console
Navigate to ```Events``` tab in the console and create a new ```Event Trigger```.
We shall create a new trigger when a new user is registered
- Trigger operation: Insert
- WebHook URL: (Your API that will talk to SendGrid)

### Testing
Test this out by creating a new user in the ```users``` table.
You will find that an email will be sent because the Hasura ```Event Trigger``` had notified the web service we created to send an email via ```SendGrid```



# Advanced Hasura tutorial

[See link here](https://hasura.io/learn/graphql/hasura-auth-slack/setup/)

## Apply migrations
Downloading the zip file contains the postgres SQL schema for our database and the hasura metadata for the object relationship mapping.

Running ```hasura migrate --admin-secret secret apply``` will seed the database and hasura graphql mapping for us.

This command should be applied where a folder called ```migrations``` contains:
- SQL file  
- yaml file  

## Roles for the data
We first need to begin by asking ourselves:
- What roles should exist for this application?
- What levels of access should each role have for the data?

We realize it is simply a ```user``` role
The ```user``` role shall have limited permissions on the tables
- Users
- Workspaces
- Channels
- Channel Threads
- Channel Thread Message

## Access control 
When we define the levels of access for the ```user``` role for our application data we can easily do this through the web console.
For example:
- Users can look up data about themselves
- Users can look up other users of the same workspace

This can look something like this:
```json
// Recall that X-Hasura-User-Id is provided as a Header field by GQL request
{
  "_or": [
    {
      "id": {
        "_eq": "X-Hasura-User-Id"
      }
    },
    {
      "workspace_members": {
        "user_id": {
          "_eq": "X-Hasura-User-Id"
        }
      }
    }
  ]
}
```

### Integrating with an Auth service
https://hasura.io/learn/graphql/hasura-auth-slack/choosing-jwt-mode/

You can use a service like Auth0 such that when you login as a user on their service, Auth0 will provide a JSON web token that contains a uuid.

This uuid shall be the same value as our user id we define in our database.
Therefore
X-Hasura-User-Id = Auth0-uuid

It would be up to the auth service to define how you configure the rules and how to put the custom X-Hasura-* headers upon receiving the JWT.

For example:
We defined custom rules in our Auth0 application to inject the hasura namespace in the JWT context.

The client logging in to Auth0 would receive this Token and forward it to the Hasura Graphql Server.

Alternatively if we want a single interface; the client can directly query an auth request to the hasura server. The hasura server will redirect that request to Auth0. The response comes back from Auth0 and hasura will then forward it back to the client.

Client will most likely append the token as a Header field in the Authorization.

# Metabase Analytics

This is a good blog on how to set up metabase 
[See this link](https://www.alibabacloud.com/blog/how-to-setup-postgresql-server-for-metabase_594913)


We will need to add create a new user and database for metabase.
Run these commands in the postgres container
```SQL
CREATE USER metabase WITH PASSWORD 'metabase';
CREATE DATABASE metabasedb; -- This cant run as part of hasura migration command
GRANT ALL PRIVILEGES ON DATABASE metabasedb to metabase;
```

Now uncomment the metabase image in ```docker-compose.yaml```
```dockerfile
  metabase: 
    image: metabase/metabase:latest
    ports:
      - "3000:3000"    
    environment:
      MB_DB_TYPE: postgres 
      MB_DB_DBNAME: metabasedb
      MB_DB_PORT: 5432
      MB_DB_USER: metabase
      MB_DB_PASS: metabase
      MB_DB_HOST: postgres
      MB_EMOJI_IN_LOGS: "true" # why not :)
    depends_on:
    - "postgres"      
```

It is worth noting we are creating a new database ```metabasedb```. This is for metabase itself to store data about our data. 

Opening up ```localhost:3000``` on our browser asks us a few questions about the database setup on metabase.

We connect to our postgres DB with the *ADMIN* credentials.

Thats it!.

Now when we add data to the postgres DB, metabase will pick it up.


# Posthog analytics