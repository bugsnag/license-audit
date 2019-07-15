# Bootsnag

Bootsnag allows us to control our development installation of Bugsnag - including running all the services in containers and controlling them.

## Development
### Static Code Analyzer
We should be aiming to create a code base that complies with good Ruby coding practice where reasonable.  We have decided that to best way to standardize and check Ruby code is to use [Rubocop](https://github.com/bbatsov/rubocop) and it's rule set.
For internal tools, it is less critical that all rules should be complied with, but that should be the aim, where it is not unreasonably expensive to do so.
#### Installing Rubocop
Follow the instructions on https://github.com/bbatsov/rubocop#installation
#### Running the test suit
From the bootsnag directory.
* For manual testing, from the bootsnag directory run:
```
rubocop --color  -E lib | less
```
* For manual testing, ignoring Line Length and Documentation rules
```
rubocop --color --except Metrics/LineLength,Style/Documentation -E lib | less 
```
* To add permanent rule modifications or to disable rules, edit `.rubocop.yml`
* To generate an `.rubocop_todo.yml` exception file that acts as a TODO list for fixing issues
```
rubocop --auto-gen-config -E lib
```
* Things you have decided to permanently ignore, add the exception from `.rubocop_todo.yml` into `.rubocop.yml`
* Should be aiming to remove all rule exceptions from `.rubocop_todo.yml`

