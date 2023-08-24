package video.api.flutter.uploader

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.PluginRegistry

/**
 * Check if the app has the given permission.
 * Only for a single permission.
 */
class PermissionManager(
    private val context: Context,
) : PluginRegistry.RequestPermissionsResultListener {
    private var uniqueRequestCode = 1

    private val listeners = mutableMapOf<Int, IListener>()
    private fun hasPermission(permission: String) =
        context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    fun requestPermission(
        activity: Activity,
        permission: String,
        onGranted: () -> Unit,
        onShowPermissionRationale: (() -> Unit) -> Unit,
        onDenied: () -> Unit
    ) {
        requestPermission(activity, permission, object : IListener {
            override fun onGranted() {
                onGranted()
            }

            override fun onShowPermissionRationale(onRequiredPermissionLastTime: () -> Unit) {
                onShowPermissionRationale(onRequiredPermissionLastTime)
            }

            override fun onDenied() {
                onDenied()
            }
        })
    }

    private fun requestPermission(
        activity: Activity,
        permission: String,
        listener: IListener
    ) {
        val currentRequestCode = synchronized(this) {
            uniqueRequestCode++
        }
        listeners[currentRequestCode] = listener
        when {
            hasPermission(permission) -> listener.onGranted()
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission) -> {
                listener.onShowPermissionRationale {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(permission),
                        currentRequestCode
                    )
                }
            }

            else -> ActivityCompat.requestPermissions(
                activity,
                arrayOf(permission),
                currentRequestCode
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ): Boolean {
        val listener = listeners[requestCode] ?: return false
        listeners.remove(requestCode)

        if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            listener.onGranted()
        } else {
            listener.onDenied()
        }

        return listeners.isEmpty()
    }

    interface IListener {
        fun onGranted()
        fun onShowPermissionRationale(onRequiredPermissionLastTime: () -> Unit)
        fun onDenied()
    }
}