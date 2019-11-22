'use strict';

const Sheet = require('google-spreadsheet');

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};

const private_key = process.env.SHEETS_PRIVATE_KEY;
const creds = {
    "type": "service_account",
    "project_id": "jovial-archive-142806",
    "private_key_id": "28eb154b30d7e6df637be06b4aa135dc2c0e94e7",
    "private_key": private_key.replaceAll('\\n', '\n'),
    "client_email": "test-email-signup@jovial-archive-142806.iam.gserviceaccount.com",
    "client_id": "109363167019841635202",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test-email-signup%40jovial-archive-142806.iam.gserviceaccount.com"
}

console.log(creds)

const doc = new Sheet('1FV5nYK3ic3PgMzPYeKNrgM7CVJrsiVe1r_wW8iX6k3s');

exports.handler = function (event, context, callback) {
    doc.useServiceAccountAuth(creds, function (err) {
        if (err) {
            console.log(err);
        }

        const email = "bert@e.tk"
        doc.addRow(1, { "email": email }, function (err, response) {
            if (err) {
                console.log(err)
            }
            if (response.email === email) {
                callback(err, {statusCode: 200, body: email})
            }
        });
    });
};