cfg = require('../../src/config')('testing')

Db = require('mongodb').Db
Server = require('mongodb').Server
dbConfig = cfg['central-server'].database

async = require 'async'
require 'datejs'

metricsHelpers = require '../../src/metrics_helpers'
should = require 'should'

describe 'Testing metrics', () ->

  db = null

  before (done) ->
    db = new Db(dbConfig.db, new Server(dbConfig.host, 27017, {}))
    db.open (err, db) ->
      db.dropDatabase (err, result) ->
        done err

  ###
  # TOTAL COUNTS METRICS TESTS
  ###
  describe 'testing basic total counts', () ->

    it 'should correctly count users', (done) ->
      testData = [
        {test: 1}
        {test: 1}
        {test: 1}
        {test: 1}
      ]
      db.collection 'users', (err, collection) ->
        collection.insert testData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'users', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

    it 'should correctly count projects', (done) ->
      testData = [
        {test: 1}
        {test: 1}
      ]
      db.collection 'projects', (err, collection) ->
        collection.insert testData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'projects', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

    it 'should correctly count accounts', (done) ->
      testData = [
        {test: 1}
        {test: 1}
        {test: 1}
        {test: 1}
        {test: 1}
      ]
      db.collection 'accounts', (err, collection) ->
        collection.insert testData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'accounts', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

    it 'should correctly count invites', (done) ->
      testData = [
        {test: 1}
        {test: 1}
        {test: 1}
      ]
      db.collection 'invites', (err, collection) ->
        collection.insert testData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'invites', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

    it 'should correctly count requirements', (done) ->
      testData = [
        {test: 1}
      ]
      db.collection 'requirements', (err, collection) ->
        collection.insert testData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'requirements', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

    it 'should correctly count requirement_items', (done) ->
      testData = [
        {test: 1}
        {test: 1}
        {test: 1}
      ]
      db.collection 'requirement_items', (err, collection) ->
        collection.insert testData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'requirement_items', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

    it 'should correctly count active payments', (done) ->
      testData = [
        {test: 1}
        {test: 1}
        {test: 1}
      ]
      endedPremiums = [
        {test: 1, endDate: new Date()}
      ]
      allData = testData.concat endedPremiums
      db.collection 'premiumstatuses', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'premiumstatuses', (err, metrics) ->
            metrics.total.should.equal testData.length
            done err

  ###
  # TODAY METRICS TESTS
  ###
  describe 'testing todays count metrics', () ->

    before (done) ->
      db.dropDatabase (err, result) ->
        done err

    it 'should return a count of users created in past 24h', (done) ->
      testDataToday = [
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
      ]
      testDataYesterday = [
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
      ]
      allData = testDataToday.concat testDataYesterday

      db.collection 'users', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'users', (err, metrics) ->
            metrics.today.should.equal testDataToday.length
            done err

    it 'should return a count of projects created in past 24h', (done) ->
      testDataToday = [
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
      ]
      testDataYesterday = [
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
      ]
      allData = testDataToday.concat testDataYesterday

      db.collection 'projects', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'projects', (err, metrics) ->
            metrics.today.should.equal testDataToday.length
            done err

    it 'should return a count of accounts created in past 24h', (done) ->
      testDataToday = [
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date().addHours(-23)}
      ]
      testDataYesterday = [
        {test: 1, created_ts: new Date().addHours(-25)}
      ]
      allData = testDataToday.concat testDataYesterday

      db.collection 'accounts', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'accounts', (err, metrics) ->
            metrics.today.should.equal testDataToday.length
            done err

    it 'should return a count of invites created in past 24h', (done) ->
      testDataToday = [
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
      ]
      testDataYesterday = [
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
      ]
      allData = testDataToday.concat testDataYesterday

      db.collection 'invites', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'invites', (err, metrics) ->
            metrics.today.should.equal testDataToday.length
            done err

    it 'should return a count of requirements created in past 24h', (done) ->
      testDataToday = [
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
      ]
      testDataYesterday = [
        {test: 1, created_ts: new Date().addHours(-25)}
      ]
      allData = testDataToday.concat testDataYesterday

      db.collection 'requirements', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'requirements', (err, metrics) ->
            metrics.today.should.equal testDataToday.length
            done err

    it 'should return a count of active premiumstatuses created in past 24h', (done) ->
      testDataTodayActive = [
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
        {test: 1, created_ts: new Date()}
      ]
      testDataToday = [
        {test: 1, created_ts: new Date(), endDate: new Date()}
        {test: 1, created_ts: new Date(), endDate: new Date()}
      ]
      testDataYesterday = [
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
        {test: 1, created_ts: new Date().addHours(-25)}
      ]
      allData = testDataToday.concat testDataYesterday, testDataTodayActive

      db.collection 'premiumstatuses', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'premiumstatuses', (err, metrics) ->
            metrics.today.should.equal testDataTodayActive.length
            done err

  ###
  # WEEKLY METRICS TESTS
  ###
  describe 'testing weekly count metrics', () ->

    before (done) ->
      db.dropDatabase (err, result) ->
        done err

    it 'should return a count of users created in past 7 days', (done) ->
      testDataThisWeek = [
        {test: 1, created_ts: new Date().addDays(-2)}
        {test: 1, created_ts: new Date().addDays(-2)}
      ]
      testData2WeeksAgo = [
        {test: 1, created_ts: new Date().add(-15).day()}
        {test: 1, created_ts: new Date().add(-15).day()}
        {test: 1, created_ts: new Date().add(-15).day()}
      ]
      allData = testDataThisWeek.concat testData2WeeksAgo

      db.collection 'users', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'users', (err, metrics) ->
            metrics.week.should.equal testDataThisWeek.length
            done err

    it 'should return a count of projects created in past 7 days', (done) ->
      testDataThisWeek = [
        {test: 1, created_ts: new Date().addDays(-2)}
      ]
      testData2WeeksAgo = [
        {test: 1, created_ts: new Date().add(-15).day()}
      ]
      allData = testDataThisWeek.concat testData2WeeksAgo

      db.collection 'projects', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'projects', (err, metrics) ->
            metrics.week.should.equal testDataThisWeek.length
            done err

    it 'should return a count of accounts created in past 7 days', (done) ->
      testDataThisWeek = [
        {test: 1, created_ts: new Date().addDays(-2)}
        {test: 1, created_ts: new Date().addDays(-2)}
        {test: 1, created_ts: new Date().addDays(-2)}
      ]
      testData2WeeksAgo = [
        {test: 1, created_ts: new Date().add(-15).day()}
      ]
      allData = testDataThisWeek.concat testData2WeeksAgo

      db.collection 'accounts', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'accounts', (err, metrics) ->
            metrics.week.should.equal testDataThisWeek.length
            done err

    it 'should return a count of invites created in past 7 days', (done) ->
      testDataThisWeek = [
        {test: 1, created_ts: new Date().addDays(-2)}
        {test: 1, created_ts: new Date().addDays(-2)}
      ]
      testData2WeeksAgo = [
        {test: 1, created_ts: new Date().add(-15).day()}
        {test: 1, created_ts: new Date().add(-15).day()}
        {test: 1, created_ts: new Date().add(-15).day()}
      ]
      allData = testDataThisWeek.concat testData2WeeksAgo

      db.collection 'invites', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'invites', (err, metrics) ->
            metrics.week.should.equal testDataThisWeek.length
            done err

    it 'should return a count of requirements created in past 7 days', (done) ->
      testDataThisWeek = [
        {test: 1, created_ts: new Date().addDays(-2)}
        {test: 1, created_ts: new Date().addDays(-2)}
      ]
      testData2WeeksAgo = [
        {test: 1, created_ts: new Date().add(-15).day()}
        {test: 1, created_ts: new Date().add(-15).day()}
      ]
      allData = testDataThisWeek.concat testData2WeeksAgo

      db.collection 'requirements', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'requirements', (err, metrics) ->
            metrics.week.should.equal testDataThisWeek.length
            done err

    it 'should return a count of active premiumstatuses created in past 7 days', (done) ->
      testDataThisWeek = [
        {test: 1, created_ts: new Date().addDays(-2), endDate: new Date()}
      ]
      testDataThisWeekActive = [
        {test: 1, created_ts: new Date().addDays(-1)}
        {test: 1, created_ts: new Date().addDays(-2)}
      ]
      testData2WeeksAgo = [
        {test: 1, created_ts: new Date().add(-15).day()}
        {test: 1, created_ts: new Date().add(-15).day()}
      ]
      allData = testDataThisWeek.concat testData2WeeksAgo, testDataThisWeekActive

      db.collection 'premiumstatuses', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'premiumstatuses', (err, metrics) ->
            metrics.week.should.equal testDataThisWeekActive.length
            done err

  ###
  # MONTHLY METRICS TESTS
  ###
  describe 'testing monthly count metrics', () ->

    before (done) ->
      db.dropDatabase (err, result) ->
        done err

    it 'should return a count of users created in past 30 days', (done) ->
      testDataThisMonth = [
        {test: 1, created_ts: new Date().add(-20).day()}
      ]
      testData3MonthsAgo = [
        {test: 1, created_ts: Date.today().add(-3).month()}
        {test: 1, created_ts: Date.today().add(-3).month()}
        {test: 1, created_ts: Date.today().add(-3).month()}
      ]
      allData = testDataThisMonth.concat testData3MonthsAgo

      db.collection 'users', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'users', (err, metrics) ->
            metrics.month.should.equal testDataThisMonth.length
            done err

    it 'should return a count of projects created in past 30 days', (done) ->
      testDataThisMonth = [
        {test: 1, created_ts: new Date().add(-7).day()}
      ]
      testData3MonthsAgo = [
        {test: 1, created_ts: Date.today().add(-3).month()}
      ]
      allData = testDataThisMonth.concat testData3MonthsAgo

      db.collection 'projects', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'projects', (err, metrics) ->
            metrics.month.should.equal testDataThisMonth.length
            done err

    it 'should return a count of accounts created in past 30 days', (done) ->
      testDataThisMonth = [
      ]
      testData3MonthsAgo = [
        {test: 1, created_ts: Date.today().add(-3).month()}
      ]
      allData = testDataThisMonth.concat testData3MonthsAgo

      db.collection 'accounts', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'accounts', (err, metrics) ->
            metrics.month.should.equal testDataThisMonth.length
            done err

    it 'should return a count of invites created in past 30 days', (done) ->
      testDataThisMonth = [
        {test: 1, created_ts: new Date().add(-10).day()}
        {test: 1, created_ts: new Date().add(-29).day()}
      ]
      testData3MonthsAgo = [
        {test: 1, created_ts: Date.today().add(-3).month()}
      ]
      allData = testDataThisMonth.concat testData3MonthsAgo

      db.collection 'invites', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'invites', (err, metrics) ->
            metrics.month.should.equal testDataThisMonth.length
            done err

    it 'should return a count of requirements created in past 30 days', (done) ->
      testDataThisMonth = [
        {test: 1, created_ts: new Date().add(-1).day()}
        {test: 1, created_ts: new Date().add(-20).day()}
      ]
      testData3MonthsAgo = [
        {test: 1, created_ts: new Date().add(-31).day()}
        {test: 1, created_ts: Date.today().add(-3).month()}
      ]
      allData = testDataThisMonth.concat testData3MonthsAgo

      db.collection 'requirements', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'requirements', (err, metrics) ->
            metrics.month.should.equal testDataThisMonth.length
            done err

    it 'should return a count of active premiumstatuses created in past 30 days', (done) ->
      testDataThisMonthActive = [
        {test: 1, created_ts: new Date().add(-3).day()}
        {test: 1, created_ts: new Date().add(-18).day()}
      ]
      testDataThisMonth = [
        {test: 1, created_ts: new Date().add(-1).day(), endDate: new Date()}
        {test: 1, created_ts: new Date().add(-20).day(), endDate: new Date()}
      ]
      testData3MonthsAgo = [
        {test: 1, created_ts: new Date().add(-31).day()}
        {test: 1, created_ts: Date.today().add(-3).month()}
      ]
      allData = testDataThisMonth.concat testData3MonthsAgo, testDataThisMonthActive

      db.collection 'premiumstatuses', (err, collection) ->
        collection.insert allData, safe: true, (err, results) ->
          metricsHelpers.basicCounts 'premiumstatuses', (err, metrics) ->
            metrics.month.should.equal testDataThisMonthActive.length
            done err

  ###
  # TIME SERIES METRICS TESTS
  ###
  describe 'testing time series related methods', () ->

    beforeEach (done) ->
      db.dropDatabase (err, result) ->
        done err

    # Test data
    date1DayAgo = Date.today().add(-1).day()
    date2DaysAgo = Date.today().add(-2).day()
    date3DaysAgo = Date.today().add(-3).day()
    date7DaysAgo = Date.today().add(-7).day()

    testYesterday = [
      {test: 1, created_ts: date1DayAgo}
      {test: 1, created_ts: date1DayAgo}
      {test: 1, created_ts: date1DayAgo}
    ]
    test2DaysAgo = [
      {test: 1, created_ts: date2DaysAgo}
    ]
    test3DaysAgo = [
      {test: 1, created_ts: date3DaysAgo}
      {test: 1, created_ts: date3DaysAgo}
    ]
    test7DaysAgo = [
      {test: 1, created_ts: date7DaysAgo}
    ]
    allData = testYesterday.concat test2DaysAgo, test3DaysAgo, test7DaysAgo

    it 'should produce array of counts of users created each day', (done) ->
      db.collection 'users', (err, users) ->
        users.insert allData, safe:true, (err, results) ->
          metricsHelpers.dailyCounts 'users', (err, results) ->
            resultsDayAgo = (obj for obj in results when Date.equals obj._id, date1DayAgo)
            results2DaysAgo = (obj for obj in results when Date.equals obj._id, date2DaysAgo)
            results3DaysAgo = (obj for obj in results when Date.equals obj._id, date3DaysAgo)
            results7DaysAgo = (obj for obj in results when Date.equals obj._id, date7DaysAgo)

            resultsDayAgo[0].value.should.equal testYesterday.length
            results2DaysAgo[0].value.should.equal test2DaysAgo.length
            results3DaysAgo[0].value.should.equal test3DaysAgo.length
            results7DaysAgo[0].value.should.equal test7DaysAgo.length
            done()

    it 'should produce array of counts of active premiumstatuses created each day', (done) ->
      pstestYesterday = [
        {test: 1, created_ts: date1DayAgo}
        {test: 1, created_ts: date1DayAgo}
        {test: 1, created_ts: date1DayAgo}
      ]
      pstest2DaysAgo = [
        {test: 1, created_ts: date2DaysAgo}
      ]
      pstest3DaysAgo = [
        {test: 1, created_ts: date3DaysAgo}
        {test: 1, created_ts: date3DaysAgo}
      ]
      pstest7DaysAgo = [
        {test: 1, created_ts: date7DaysAgo}
      ]
      pstestYesterdayInactive = [
        {test: 1, created_ts: date1DayAgo, endDate: new Date()}
      ]
      pstest2DaysAgoInactive = [
        {test: 1, created_ts: date2DaysAgo, endDate: new Date()}
      ]
      pstest3DaysAgoInactive = [
        {test: 1, created_ts: date3DaysAgo, endDate: new Date()}
      ]
      pstest7DaysAgoInactive = [
        {test: 1, created_ts: date7DaysAgo, endDate: new Date()}
      ]
      psallData = pstestYesterday.concat pstest2DaysAgo, pstest3DaysAgo, pstest7DaysAgo, pstestYesterdayInactive, pstest2DaysAgoInactive, pstest3DaysAgoInactive, pstest7DaysAgoInactive

      db.collection 'premiumstatuses', (err, users) ->
        users.insert psallData, safe:true, (err, results) ->
          metricsHelpers.dailyCounts 'premiumstatuses', (err, results) ->
            resultsDayAgo = (obj for obj in results when Date.equals obj._id, date1DayAgo)
            results2DaysAgo = (obj for obj in results when Date.equals obj._id, date2DaysAgo)
            results3DaysAgo = (obj for obj in results when Date.equals obj._id, date3DaysAgo)
            results7DaysAgo = (obj for obj in results when Date.equals obj._id, date7DaysAgo)

            resultsDayAgo[0].value.should.equal testYesterday.length
            results2DaysAgo[0].value.should.equal test2DaysAgo.length
            results3DaysAgo[0].value.should.equal test3DaysAgo.length
            results7DaysAgo[0].value.should.equal test7DaysAgo.length
            done()

    it 'should create array of objects with dates and rolling sum', (done) ->
      db.collection 'users', (err, users) ->
        users.insert allData, safe: true, (err, results) ->
          metricsHelpers.dailyCounts 'users', (err, results) ->
            metricsHelpers.datesAndRollingSums results, (results) ->
              results[0].count.should.equal 1
              results[1].count.should.equal 3
              results[2].count.should.equal 4
              results[3].count.should.equal 7
              done()

  ###
  # ACCOUNT METRIC TESTS
  ###
  describe 'testing account specific metrics', () ->

    testData = []

    zeroToSix = 0
    fiveToEleven = 0
    tenToSixteen = 0
    sixteenToTwentyOne = 0
    twentyPlus = 0

    for i in [0..9]
      ranMemLimit = Math.floor(Math.random()*30) + 1

      testAccount = {}
      testAccount['members'] = []
      for j in [0..ranMemLimit-1]
        testAccount['members'].push {1: 1}

      if ranMemLimit > 0 and ranMemLimit < 6
        zeroToSix += 1
      else if ranMemLimit > 5 and ranMemLimit < 11
        fiveToEleven += 1
      else if ranMemLimit > 10 and ranMemLimit < 16
        tenToSixteen += 1
      else if ranMemLimit > 15 and ranMemLimit < 21
        sixteenToTwentyOne += 1
      else if ranMemLimit > 20 
        twentyPlus += 1

      testData.push testAccount

    # Drop database and add test data
    before (done) ->
      db.dropDatabase (err, result) ->
        db.collection 'accounts', (err, accounts) ->
          accounts.insert testData, safe: true, (err, results) ->
            done err

    it 'should count the number of accounts with a member count of 1 - 5', (done) ->
      metricsHelpers.memberCounts 'accounts', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.oneFive.should.equal zeroToSix
          done()

    it 'should count the number of accounts with a member count of 6 - 10', (done) ->
      metricsHelpers.memberCounts 'accounts', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.sixTen.should.equal fiveToEleven
          done()

    it 'should count the number of accounts with a member count of 11 - 15', (done) ->
      metricsHelpers.memberCounts 'accounts', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.elevenFifteen.should.equal tenToSixteen
          done()
      
    it 'should count the number of accounts with a member count of 15 - 20', (done) ->
      metricsHelpers.memberCounts 'accounts', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.sixteenTwenty.should.equal sixteenToTwentyOne
          done()
      
    it 'should count the number of accounts with a member count of 20+', (done) ->
      metricsHelpers.memberCounts 'accounts', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.twentyPlus.should.equal twentyPlus
          done()

  ###
  # PROJECT METRIC TESTS
  ###
  describe 'testing project specific metrics', () ->

    testData = []

    zeroToSix = 0
    fiveToEleven = 0
    tenToSixteen = 0
    sixteenToTwentyOne = 0
    twentyPlus = 0

    for i in [0..9]
      ranMemLimit = Math.floor(Math.random()*30) + 1

      testAccount = {}
      testAccount['members'] = []
      for j in [0..ranMemLimit-1]
        testAccount['members'].push {1: 1}

      if ranMemLimit > 0 and ranMemLimit < 6
        zeroToSix += 1
      else if ranMemLimit > 5 and ranMemLimit < 11
        fiveToEleven += 1
      else if ranMemLimit > 10 and ranMemLimit < 16
        tenToSixteen += 1
      else if ranMemLimit > 15 and ranMemLimit < 21
        sixteenToTwentyOne += 1
      else if ranMemLimit > 20 
        twentyPlus += 1

      testData.push testAccount

    # Drop database and add test data
    before (done) ->
      db.dropDatabase (err, result) ->
        db.collection 'projects', (err, projects) ->
          projects.insert testData, safe: true, (err, results) ->
            done err

    it 'should count the number of projects with a member count of 1 - 5', (done) ->
      metricsHelpers.memberCounts 'projects', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.oneFive.should.equal zeroToSix
          done()

    it 'should count the number of projects with a member count of 6 - 10', (done) ->
      metricsHelpers.memberCounts 'projects', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.sixTen.should.equal fiveToEleven
          done()

    it 'should count the number of projects with a member count of 11 - 15', (done) ->
      metricsHelpers.memberCounts 'projects', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.elevenFifteen.should.equal tenToSixteen
          done()
      
    it 'should count the number of projects with a member count of 15 - 20', (done) ->
      metricsHelpers.memberCounts 'projects', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.sixteenTwenty.should.equal sixteenToTwentyOne
          done()
      
    it 'should count the number of projects with a member count of 20+', (done) ->
      metricsHelpers.memberCounts 'projects', (err, counts) ->
        if err
          console.log err

        metricsHelpers.memberCountDists counts, (distributions) ->
          distributions.twentyPlus.should.equal twentyPlus
          done()

  ###
  # INVITE METRIC TESTS
  ###
  describe 'testing invite specific metrics', () ->

    describe 'testing invite status count metrics', () ->

      # Drop database and add test data
      before (done) ->
        db.dropDatabase (err, result) ->
          db.collection 'invites', (err, invites) ->
            invites.insert allData, safe: true, (err, a_results) ->
              done err

      # Test data
      testInvitedInvites = [
        {test: 1, status: 'invited'}
        {test: 1, status: 'invited'}
        {test: 1, status: 'invited'}
      ]
      testAcceptedInvites = [
        {test: 1, status: 'accepted'}
      ]
      testDeclinedInvites = [
        {test: 1, status: 'declined'}
        {test: 1, status: 'declined'}
        {test: 1, status: 'declined'}
        {test: 1, status: 'declined'}
      ]
      testFailedInvites = [
        {test: 1, status: 'failed'}
        {test: 1, status: 'failed'}
      ]
      testCancelledInvites = [
        {test: 1, status: 'cancelled'}
      ]
      testResentInvites = [
        {test: 1, status: 'resent'}
        {test: 1, status: 'resent'}
        {test: 1, status: 'resent'}
      ]
      allData = testInvitedInvites.concat(
        testAcceptedInvites, 
        testDeclinedInvites, 
        testFailedInvites, 
        testCancelledInvites, 
        testResentInvites
        )

      it 'should find the total count of the invites with a status of \'invite\'',
        (done) ->
            metricsHelpers.getInviteStatusCounts (err, counts) ->
              counts.invited.should.equal testInvitedInvites.length
              done err

      it 'should find the total count of the invites with a status of \'accepted\'',
        (done) ->
            metricsHelpers.getInviteStatusCounts (err, counts) ->
              counts.accepted.should.equal testAcceptedInvites.length
              done err

      it 'should find the total count of the invites with a status of \'declined\'',
        (done) ->
            metricsHelpers.getInviteStatusCounts (err, counts) ->
              counts.declined.should.equal testDeclinedInvites.length
              done err

      it 'should find the total count of the invites with a status of \'failed\'',
        (done) ->
            metricsHelpers.getInviteStatusCounts (err, counts) ->
              counts.failed.should.equal testFailedInvites.length
              done err

      it 'should find the total count of the invites with a status of \'cancelled\'',
        (done) ->
            metricsHelpers.getInviteStatusCounts (err, counts) ->
              counts.cancelled.should.equal testCancelledInvites.length
              done err

      it 'should find the total count of the invites with a status of \'resent\'',
        (done) ->
            metricsHelpers.getInviteStatusCounts (err, counts) ->
              counts.resent.should.equal testResentInvites.length
              done err

    describe 'testing invite status count metrics', () ->

      # Drop database and add test data
      before (done) ->
        db.dropDatabase (err, result) ->
          db.collection 'invites', (err, invites) ->
            invites.insert allData, safe: true, (err, a_results) ->
              done err

      # Test data
      testProjectInvites = [
        {test: 1, fromType: 'project'}
        {test: 1, fromType: 'project'}
        {test: 1, fromType: 'project'}
        {test: 1, fromType: 'project'}
      ]
      testAccountInvites = [
        {test: 1, fromType: 'account'}
        {test: 1, fromType: 'account'}
      ]
      allData = testProjectInvites.concat testAccountInvites

      it 'should find the total count of project invites', (done) ->
        metricsHelpers.getInviteTypeCounts (err, counts) ->
          counts.project.should.equal testProjectInvites.length
          done err

      it 'should find the total count of account invites', (done) ->
        metricsHelpers.getInviteTypeCounts (err, counts) ->
          counts.account.should.equal testAccountInvites.length
          done err

  describe 'testing user specific metrics', () ->

    totalPersonas = 0
    testData = [
      {personas: []}
      {personas: []}
      {personas: []}
      {personas: []}
    ]

    for i in testData
      personaLimit = Math.floor(Math.random()*10)
      totalPersonas += personaLimit
      j = 0
      while j < personaLimit
        i.personas.push {persona: 1}
        j++

    # Drop database and add test data
    before (done) ->
      db.dropDatabase (err, result) ->
        db.collection 'users', (err, users) ->
          users.insert testData, safe: true, (err, a_results) ->
            done err

    it 'should find total personas per user', (done) ->
      metricsHelpers.getTotalPersonas (err, total) ->
        totalPersonas.should.equal total
        done()

