gulp = require 'gulp'
gutil = require 'gulp-util'

paths =
  src: './src/**/*.coffee'
  test: './test/**/*.coffee'
  coverage: './coverage/**/lcov.info'
  coverageDir: './coverage/'
  compiledDir: './.tmp/'
  compiledSrc: './.tmp/src/**/*.js'
  compiledSrcDir: './.tmp/src/'
  compiledTest: './.tmp/test/**/*.js'
  compiledTestDir: './.tmp/test/'
  buildDir: './lib/'

hubotHelp =
  init: ->
    through = require 'through2'
    through.obj (file, encoding, next) ->
      help = for line in file.contents.toString().split('\n')
        break unless line[0] is '#' or line.substring(0, 2) is '//'
        line.replace(new RegExp('^#(\\s*)'), '//$1')
      file.hubotHelp = help.join('\n') + '\n'
      next null, file
  write: ->
    through = require 'through2'
    through.obj (file, encoding, next) ->
      return next(null, file) unless file.hubotHelp?
      file.contents = Buffer.concat [
        new Buffer(file.hubotHelp)
        file.contents
      ]
      next null, file

gulp.task 'clean', (done) ->
  del = require 'del'
  del [
    paths.compiledDir
    paths.coverageDir
    paths.buildDir
  ], done

gulp.task 'coveralls', ->
  coveralls = require 'gulp-coveralls'
  gulp
    .src paths.coverage
    .pipe coveralls()

gulp.task 'build', ->
  coffee = require 'gulp-coffee'
  gulp
    .src paths.src
    .pipe hubotHelp.init()
    .pipe coffee(bare: true).on('error', gutil.log)
    .pipe hubotHelp.write()
    .pipe gulp.dest(paths.buildDir)

gulp.task 'compile-src', ->
  coffee = require 'gulp-coffee'
  sourcemaps = require 'gulp-sourcemaps'
  gulp
    .src paths.src
    .pipe sourcemaps.init()
    .pipe hubotHelp.init()
    .pipe coffee(bare: true).on('error', gutil.log)
    .pipe hubotHelp.write()
    .pipe sourcemaps.write()
    .pipe gulp.dest(paths.compiledSrcDir)

gulp.task 'compile-test', ->
  coffee = require 'gulp-coffee'
  espower = require 'gulp-espower'
  sourcemaps = require 'gulp-sourcemaps'
  gulp
    .src paths.test
    .pipe sourcemaps.init()
    .pipe coffee(bare: true).on('error', gutil.log)
    .pipe espower()
    .pipe sourcemaps.write()
    .pipe gulp.dest(paths.compiledTestDir)

gulp.task 'test', ['compile-src', 'compile-test'], ->
  istanbul = require 'gulp-istanbul'
  mocha = require 'gulp-mocha'
  gulp
    .src paths.compiledSrc
    .pipe istanbul()
    .on 'finish', ->
      gulp
        .src paths.compiledTest
        .pipe mocha().on('error', gutil.log)
        .pipe istanbul.writeReports(paths.coverageDir)

gulp.task 'watch', ->
  gulp.watch [paths.src, paths.test], ['test']

gulp.task 'default', ['build']
