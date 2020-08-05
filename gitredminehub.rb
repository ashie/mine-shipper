#!/usr/bin/env ruby

$LOAD_PATH.unshift("./lib")

require 'gitredhubmine/app'

app = GitRedHubMine::App.new
app.run
