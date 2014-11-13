
TH = require "./test_helper"
assert = require "assert"
should = require "should"
phantom = require 'phantom'
request = require 'supertest'

Order = TH.require "models/Order.iced"
MailDrop = TH.require "models/MailDrop.iced"

# Testing the pages loading
describe 'Load Page', ()->
	describe ':login', ()->
		it 'should display the login page',(done)->
			phantom.create (ph) ->
				ph.createPage (page) ->
					page.open "http://" + global.server.address().address + ":" + global.server.address().port + "/login", (status) ->
						page.evaluate (-> document.title), (result) ->
							assert.equal(result, "Login")
							ph.exit()
							done()

		it 'should display the login page (supertest)', (done) ->
			request(global.web).get('/login')
			.expect(200, /Login/, done)


# Test the Order saving into DB
describe 'Order', ()->
	describe ':save', ()->
		xit 'should save the Order and one MailDrop into DB and display them on the main page',(done)->

			# New test object
			order = new Order
				DealerID: 1
				ClientID: 1
				OrderTypeID: 1
				OrderDate: new Date()

			# Save the Order
			order.save ()->

				# Save the mailDrop for the order
				drop = new MailDrop
					OrderID: order.OrderID
					DropNumber: 1
					DropStatus: 'New'

				drop.save ()->

					# Fetch the browser page and search the just saved order in it
					phantom.create (ph) ->
						ph.createPage (page) ->
							page.open "http://127.0.0.1:" + global.server.address().port, (status) ->

								# Evaluate page and collect the title and array of jobnames texts
								# We can't pass the parameter into evaluate function with phantomjs-node
								page.evaluate ()-> 

									title: document.title
									job_names: ($(jobname).text() for jobname in $('.jobname'))

								, (result)->
									# Search just saved order in the Jobs list
									assert.notEqual(-1, result.job_names.indexOf(order.JobName));

									# We can save the screenshot of page. Coool
									#page.render('files/autobanc.png')
									ph.exit()
									done()
