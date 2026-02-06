package it.federicooldrini.rifugiebivacchi

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Log SHA-1 del certificato di firma
        try {
            val info = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNING_CERTIFICATES
            )
            
            val signingInfo = info.signingInfo
            if (signingInfo != null) {
                val signatures = if (signingInfo.hasMultipleSigners()) {
                    signingInfo.apkContentsSigners
                } else {
                    signingInfo.signingCertificateHistory
                }
                
                for (signature in signatures) {
                    val md = MessageDigest.getInstance("SHA-1")
                    md.update(signature.toByteArray())
                    val digest = md.digest()
                    
                    val hexString = digest.joinToString(":") { 
                        String.format("%02X", it)
                    }
                    
                    Log.d("CertificateInfo", "SHA-1 Fingerprint: $hexString")
                }
            } else {
                Log.w("CertificateInfo", "SigningInfo is null")
            }
        } catch (e: Exception) {
            Log.e("CertificateInfo", "Errore nel calcolo dello SHA-1: ${e.message}")
        }
    }
}
