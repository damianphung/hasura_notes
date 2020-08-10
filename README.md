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

## TODO
Continue with deployment of bot service.
- GQL client for python container AI
- Data modeling for PG database. Need to migrate from postgres firebase starter git repo