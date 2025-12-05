# DoveRunner Forensic Watermark CDN Embedder Sample for Akamai EdgeWorkers

This project serves as a sample implementation for embedding forensic watermarks using **Akamai EdgeWorkers**.
It provides the basic structure and logic required to deploy watermark embedding functionality at the edge.

For more information, refer to the [Akamai EdgeWorkers Documentation](https://techdocs.akamai.com/edgeworkers/docs/welcome-to-edgeworkers).

## Configuration

Update `config.js` with your specific settings:

```javascript
export const config = {
    "aesKey": "YOUR_AES_KEY",
    "type" : "unlabeled_a_variant",
    "availableInterval": 60000,
    "prefixFolder": ["folder1", "folder2"],
    "wmtPublicKey": "YOUR_PUBLIC_KEY", // PEM format public key for Akamai WMT
    "wmtPassword": "YOUR_PASSWORD", // Password for WMT token generation/verification
    "cpCode": "YOUR_CP_CODE" // Akamai CP Code
}
```

**wmt_type**: Indicates whether the issued token format is AES-encrypted or JWT. This corresponds to the specification provided when requesting the watermark token.
- [Watermark Token Request Specification](https://docs.doverunner.com/content-security/forensic-watermarking/embedding/session-manager/#api-data-json-format)

| Key | wmt_type | Description |
| :--- | :--- | :--- |
| `aesKey` | aes | The Site Key issued by the DoveRunner ContentSecurity Service. |
| `type` | aes, jwt | The [Watermark File Folder Structure](#watermark-file-folder-structure). Default: `unlabeled_a_variant`. |
| `availableInterval` | aes, jwt | Token validity interval in seconds (0 for infinite). |
| `prefixFolder` | aes | The top-level folder containing watermark files. Corresponds to `prefix_folder` in the [Watermark Token Request Specification](https://docs.doverunner.com/content-security/forensic-watermarking/embedding/session-manager/#api-data-json-format). |
| `wmtPublicKey` | jwt | PEM format public key for Akamai WMT. |
| `wmtPassword` | jwt | Password for WMT token generation/verification. |
| `cpCode` | jwt | Akamai CP Code. (Using Akamai NetStorage [cpCode](https://techdocs.akamai.com/netstorage/docs/create-an-upload-account#upload-directory-association) is required.) |

## Watermark File Folder Structure

### directory_prefix

- Distinguishes A/B files based on folders.

#### Example

```text
/wm-contents/output_path/cid/{0/1}/dash/stream.mpd
/wm-contents/output_path/cid/{0/1}/dash/video/0/seg-125.m4s
/wm-contents/output_path/cid/{0/1}/hls/master.m3u8
/wm-contents/output_path/cid/{0/1}/hls/video/0/0/stream.m3u8
/wm-contents/output_path/cid/{0/1}/hls/video/0/0/segment-125.ts
```

### unlabeled_a_variant

- A/B files exist in the same folder and are distinguished by filenames.

#### Example

```text
/wm-contents/output_path/cid/dash/stream.mpd
/wm-contents/output_path/cid/dash/video/0/seg-125.m4s
/wm-contents/output_path/cid/dash/video/0/b.seg-125.m4s
/wm-contents/output_path/cid/hls/master.m3u8
/wm-contents/output_path/cid/hls/video/0/0/stream.m3u8
/wm-contents/output_path/cid/hls/video/0/0/segment-125.ts
/wm-contents/output_path/cid/hls/video/0/0/b.segment-125.ts
```

## Usage

The EdgeWorkers intercepts client requests and routes them based on the URL structure:

1.  **Akamai WMT**: If the path starts with `wmt:`, it uses `akamaiWmt.js` to verify the token and rewrite the path.
2.  **DoveRunner AES**: If the path matches one of the `prefixFolder` entries, it uses `doveRunnerAes.js` to decrypt the watermark data and generate the appropriate content path.

## Deployment

1. Update the `edgeworker-version` in `bundle.json`.
2. Run `build-bundle.sh` to create a bundle file.
3. Upload the bundle to edgeWorkers.   

    3-1. If [akamai cli](https://github.com/akamai/cli) and [EdgeWorkers cli](https://github.com/akamai/cli-edgeworkers) are installed, run script.
    ```
    akamai edgeworkers upload --bundle doverunner_fwm_embedder_{version}.tgz {YOUR_EW_ID}`.
    ```  
    3-2. If akamai cli is not installed, Go to the **Akamai EdgeWorkers IDs** page, click the **Create version** button, and upload the compressed file.  
4. Select the Network (`stage`, `production`) you want to deploy to and click the **Activate version** button.