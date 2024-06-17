package com.example.nfcwallet;

import android.nfc.cardemulation.HostApduService;
import android.os.Bundle;
import android.util.Log;

public class MyHostApduService extends HostApduService {

    private static final String TAG = "MyHostApduService";
    private static final byte[] SELECT_APDU = {/* Your APDU command bytes */};
    private static final byte[] RESPONSE_OK = {(byte)0x90, (byte)0x00}; // Success response

    @Override
    public byte[] processCommandApdu(byte[] commandApdu, Bundle extras) {
        Log.i(TAG, "Received APDU: " + bytesToHex(commandApdu));
        if (matchesSelectApdu(commandApdu)) {
            return RESPONSE_OK;
        }
        return null;
    }

    @Override
    public void onDeactivated(int reason) {
        Log.i(TAG, "Deactivated: " + reason);
    }

    private boolean matchesSelectApdu(byte[] commandApdu) {
        // Implement your logic to match the APDU command
        return true;
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b));
        }
        return sb.toString();
    }
}
