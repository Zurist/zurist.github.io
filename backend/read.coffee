# This example script opens an IMAP connection to the imap and
# seeks unread messages sent by the user himself. It will then
# download those messages, parse them, and write their attachments
# to disk.

# Install node-imap with `npm install imap`
Imap = require "imap"
# Install mailparser with `npm install mailparser`
mailparser = require "mailparser"
# You need a config file with your email settings
# fs = require "fs"
# config = JSON.parse fs.readFileSync "#{process.cwd()}/config.json", "utf-8"
# config = require("./config.json")

# console.log process.env.EMAIL
# console.log process.env.PWD

imap = new Imap
    user: process.env.EMAIL
    password: process.env.PWD
    host: 'imap.gmail.com'
    port: 993
    tls: true
console.log "after imap"

subject = process.env.SUBJECT

exitOnErr = (err) ->
    console.log "inside exitOnErr"
    console.error err
    do process.exit

imap.once 'ready', () ->
    console.log "inside connect"
    imap.openBox "INBOX", true, (err, box) ->
        exitOnErr err if err
        console.log "Successfully opened Inbox"
        
        imap.search ["UNSEEN", ["SUBJECT", subject]], (err, results) ->
            exitOnErr err if err

            unless results.length
                console.log "No matched messages for #{subject}"
                do imap.end
                return

            console.log "Matched #{results.length} messages for #{subject}"
            
            fetch = imap.fetch results,
                request:
                    body: "full",
                    headers: false
            
            fetch.on "message", (message) ->
                console.log "inside message"
                 
                parser = new mailparser.MailParser
                
                parser.on "headers", (headers) ->
                  console.log "Message: #{headers.inspect}"
                
                parser.on 'end', (mail) ->
                  console.log mail.subject
                  console.log mail.text

                #message.on "data", (data) ->
                #   console.log "inside data #{data.inspect}"
                #   parser.write data.toString()

                #message.on "end", ->
                #   console.log "inside message end"
                #  do parser.end
                parser.write message
                do parser.end
             
            fetch.on "end", ->
                do imap.end

imap.once 'error', (err) ->
    console.log err

imap.once 'end', () ->
    console.log 'Connection ended'

do imap.connect
