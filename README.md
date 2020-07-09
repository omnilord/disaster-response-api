# Disaster Resources API

This API application is distilled from the efforts to mitigate resource management activities during Hurricanes Harvey, Irma, and Florence by Sketch City and Code for America.  The goal of this API project is to create an easily deployable, interoperable OpenAPI for resource information management during a disaster and make it easily deployable and accessible to the people on the ground who need fast access to resources and a map to find how to get there.

This application comes with a management UI and an OpenAPI Endpoint for use by third-party tools to index and map the resources in areas affected by disaster.

# Status

This is repo is in a very early stage of development.  While there is decent test coverage of controller end-points, there is room for more test coverage.  There are a several known defects (as of 2020-06-01) that could use some TLC, a huge stack of features to implement (new ideas, such as "you could use the ActiveAdmin Gem for [functionality]" are welcome.

# Setup

## Prerequisites
The following need to be running per a standard setup with local connection sockets:
1. PostgreSQL ~> 11
  - PL/PgSQL extension installed
  - PostGIS ~> 3.0 extension
2. Ruby ~> 2.6.5, < 2.7 (as of Rails 5.2.4.3 there are problems with Ruby 2.7)
3. Redis ~> 5.0
4. A Mapbox API key stored as an environment variable: `MAPBOX_API_KEY`

If you have an unusual setup (such as using TCP/IP for PostgreSQL connections in lieu of a Unix Socket, you will need to modify the configuration files accordingly).

## Instructions
1. Clone this repository, or if you are ready to contribute, fork then clone your fork repo.
2. Change directories to your new repository directory 
3. `rails db:setup`
4. `rails s`
5. visit `http://localhost:3000` to verify everything is setup.
6. Create an account by logging in. You will probably need to run `UPDATE users SET admin=true WHERE id=1;'` to make sure you have an administrator account locally.
7. Have fun exploring the product.

## Contributing
0. Communicate!  Before you spend hours setting up a feature, reach out to existing contributors and find out what's up.  There may be road map changes that haven't made it into a public facing document, or someone else may be many hours into a feature already.  Finding out what the status of the project is by talking with the people on the team and sharing your thoughts on how you want to participate is a great way to get started without writing a single line of code.
1. Follow good git etiquette:
2. Don't commit directly to master for features of fixes that will require more than 1 commit.
3. When starting a new feature or fix, create a feature or fix branch named with a prefix of `feature/` or `fix/`, respectively.  Use descriptive but short branch names after the `/` to concisely identify what the branch is.
4. When finished, or requesting feedback, feel free to start a Pull Request (PR).  When updating your local branch for feedback, it is not necessary to create a new PR, the existing one will be updated.
5. Features will be squash-merged.  Fixes may be squash-merged if they contain non-working commits, or execessive one-line changes.
6. All commits should have new tests written in Minitest to cover the code changes unless the fix was for something update/test-related.
7. ALWAYS RUN TESTS BEFORE COMMITTING!  Running `rails test && rails_best_practices` as a git pre-commit-hook is a great use of git features that will prevent you from committing broken code.
8. While rubocop is not in use, feel free to read bbatsov's ruby style guide and rails style guide for a general _sense_ of how source should be formatted, although go with the flow there are some slight deviations that make the source easier to read.
9. When in doubt, communicate with the team.
10. This project was built as a Ruby on Rails monolith--this means it takes advantage of Rails conventions where possible/known, and strives to implement best practices of Rails.  Future improvements will use ActionCables, Stimulus, and refine the use of partials to hone the code's hidden beauty.

Contibutions are always well, but please read _CODE_OF_CONDUCT here_ and ... <TODO>

# API Specification

TODO

# Credit

TODO (Sketch City for original Harvey and Irma code-base, Code for America for Florence, add devs/collaborators for ongoing efforts during and after this rebuild).
