import {logger} from 'log';
import {config} from './config.js';
import doveRunnerAes from '././wmt/doveRunnerAes.js';
import akamaiWmt from '././wmt/akamaiWmt.js';
import wmUtil from '././watermark-util/wmUtil.js';

const checkWatermarkPath = (reqPrefixFolder) => {
    const { prefixFolder } = config;
    if (Array.isArray(prefixFolder)) {
        return prefixFolder.includes(reqPrefixFolder);
    } else {
        return prefixFolder === reqPrefixFolder;
    }
}

export async function onClientRequest(request) {
    try {
        let finalRequestPath;
        let arrUri = request.path.split('/');
        const prefixFolder = arrUri[1];

        if (prefixFolder.startsWith('wmt:')) {
            // Using akamaiWmt
            finalRequestPath = await akamaiWmt.getContentUrl(request.path, arrUri, config);
        } else {
            // Using doveRunnerAes
            if (checkWatermarkPath(prefixFolder)) {
                // remove revoke token
                const { modifiedArrUri, hasRevokeToken } = wmUtil.removeRevokeToken(arrUri);
                arrUri = modifiedArrUri;
                const requestPath = '/' + arrUri.slice(1).join('/');

                finalRequestPath = await doveRunnerAes.getContentUrl(requestPath, arrUri, prefixFolder, config, hasRevokeToken);
            }
        }

        if (config.cpCode && finalRequestPath) {
            finalRequestPath = `/${config.cpCode}${finalRequestPath}`;
        }

        const routeInfo = { path: finalRequestPath, query: request.query }

        logger.debug('routeInfo : %s', JSON.stringify(routeInfo));
        request.route(routeInfo);
    } catch (e) {
        logger.error('error=%s', e.message);
        request.respondWith(400, {}, JSON.stringify({ error: e.message }));
    }
}
