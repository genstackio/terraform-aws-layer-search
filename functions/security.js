// noinspection ES6ConvertVarToLetConst

var crypto = require('crypto');

function jwt_decode(token, key, noVerify) {
    if (!token) throw new Error('No token supplied');
    token = token.trim().replace(/^Bearer\s+/i, '')
    var segments = token.split('.');
    if (segments.length !== 3) throw new Error('Not enough or too many segments');

    var headerSeg = segments[0];
    var payloadSeg = segments[1];
    var signatureSeg = segments[2];

    // noinspection JSUnresolvedFunction
    JSON.parse(String.bytesFrom(headerSeg, 'base64url')); // throw error if not base64
    // noinspection JSUnresolvedFunction
    var payload = JSON.parse(String.bytesFrom(payloadSeg, 'base64url'));
    if (!noVerify) {
        var signingMethod = 'sha256';
        var signingType = 'hmac';
        if (!_verify([headerSeg, payloadSeg].join('.'), key, signingMethod, signingType, signatureSeg)) throw new Error('Signature verification failed');
        if (payload['nbf'] && Date.now() < payload['nbf']*1000) throw new Error('Token not yet active');
        if (payload.exp && Date.now() > payload.exp*1000) throw new Error('Token expired');
    }

    return payload;
}

function _verify(input, key, method, type, signature) {
    if ('hmac' === type) { // noinspection JSCheckFunctionSignatures
        return signature === crypto.createHmac(method, key).update(input).digest('base64url');
    }
    throw new Error('Algorithm type not recognized');
}

// noinspection JSUnusedLocalSymbols
function handler(event) {
    var request = event.request;
    try {
        if (!request.headers['authorization'] || !request.headers['authorization'].value) {
            // noinspection ExceptionCaughtLocallyJS
            throw new Error('No Authorization header');
        }
        jwt_decode(request.headers['authorization'].value, "{{{JWT_SECRET}}}");
        delete request.headers['authorization'];
    } catch(e) {
        return {statusCode: 401, statusDescription: 'Unauthorized', headers: {'x-function-error': {value: 'Invalid Authorization Header: ' + e.message}}};
    }

    return request;
}