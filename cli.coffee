bb = require 'bluebird'
program = require('commander');
chalk = require 'chalk'

HapiGER = require('./lib/hapi_server')

cli = ->

  program
    .version('0.0.1')
    .usage('[options]')
    .description('start a hapiger server')
    .option('-p, --port <port>', 'the port to start the server on', 3456)
    .option('-e, --esm <esm>', 'select Event Store Manager [memory, pg, rethinkdb]', 'memory')
    .option('-E, --esmurl <options>', 'The url location of the ESM')
    .option('-v, --verbose', "More Output", false)

    .option('-m, --minimum_history_limit <limit>', 'Minimal amount of events for recommendations to be returned', 1)
    .option('-s, --similar_people_limit <limit>', "The number of similar people to identify", 25)
    .option('-r, --related_things_limit <limit>', "The number of related things to identify", 10)
    .option('-n, --number_of_recommendations <num>', "The number of recommendations to return", 20)
    .option('-d, --recent_event_days <days>', "The number of days an event is considered recent", 14)
    .option('-f, --previous_actions_filter <csv>', "Comma separated list of events that will not be recommended", '')
    .option('-c, --compact_database_person_action_limit <limit>', "The number of person, actions to compact to", 1500)
    .option('-C, --compact_database_thing_action_limit <limit>', "The number of thing, actions to compact to", 1500)
    .option('-h, --person_history_limit <limit>', "The amount of events in a persons history to consider when searching for recommendations", 500)
    .option('-w, --crowd_weight <weight>', "The amount of weight multiple similar people doing the same action should be considered (peer pressure)", 0)
    .parse(process.argv);

  verbose = program.verbose
  
  bb.Promise.longStackTraces() if verbose
  
  hapiger = new HapiGER({
    esm: program.esm
    esmurl: program.esmurl
    port: program.port
    minimum_history_limit: program.minimum_history_limit,
    similar_people_limit: program.similar_people_limit
    related_things_limit: program.related_things_limit
    recommendations_limit: program.number_of_recommendations,
    recent_event_days: program.recent_event_days,
    previous_actions_filter: program.previous_actions_filter.split(',').filter( (x) -> x.trim() != '')
    compact_database_person_action_limit: program.compact_database_person_action_limit
    compact_database_thing_action_limit: program.compact_database_thing_action_limit
    person_history_limit: program.person_history_limit
    crowd_weight: program.crowd_weight
  })

  hapiger.initialize()
  .then( -> hapiger.start())
  .catch((e) -> console.log "ERROR"; console.log e.stack)


module.exports = cli