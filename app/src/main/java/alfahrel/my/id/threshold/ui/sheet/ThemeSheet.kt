package alfahrel.my.id.threshold.ui.sheet

import alfahrel.my.id.threshold.R
import alfahrel.my.id.threshold.util.App
import alfahrel.my.id.threshold.util.ThemePrefs
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatDelegate
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.button.MaterialButton
import com.google.android.material.button.MaterialButtonToggleGroup
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.materialswitch.MaterialSwitch

class ThemeSheet : BottomSheetDialogFragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View = inflater.inflate(R.layout.sheet_theme, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupModeButtons(view)
        setupDynamicColorSwitch(view)
    }

    private fun setupModeButtons(view: View) {
        val btnGroup = view.findViewById<MaterialButtonToggleGroup>(R.id.btnGroupMode)
        val btnSystem = view.findViewById<MaterialButton>(R.id.btnSystem)
        val btnLight = view.findViewById<MaterialButton>(R.id.btnLight)
        val btnDark = view.findViewById<MaterialButton>(R.id.btnDark)

        val currentMode = ThemePrefs.getMode(requireContext())
        val initialButton = when (currentMode) {
            AppCompatDelegate.MODE_NIGHT_NO -> btnLight
            AppCompatDelegate.MODE_NIGHT_YES -> btnDark
            else -> btnSystem
        }
        btnGroup.check(initialButton.id)

        btnGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (!isChecked) return@addOnButtonCheckedListener
            val mode = when (checkedId) {
                R.id.btnLight -> AppCompatDelegate.MODE_NIGHT_NO
                R.id.btnDark -> AppCompatDelegate.MODE_NIGHT_YES
                else -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
            }
            ThemePrefs.setMode(requireContext(), mode)
            AppCompatDelegate.setDefaultNightMode(mode)
        }
    }

    private fun setupDynamicColorSwitch(view: View) {
        val switch = view.findViewById<MaterialSwitch>(R.id.switchDynamicColor)
        switch.isChecked = ThemePrefs.isDynamicColor(requireContext())

        switch.setOnCheckedChangeListener { _, isChecked ->
            MaterialAlertDialogBuilder(requireContext())
                .setTitle(if (isChecked) getString(R.string.dialog_enable_dynamic_color) else getString(R.string.dialog_disable_dynamic_color))
                .setMessage(getString(R.string.dialog_dynamic_color_message))
                .setPositiveButton(getString(R.string.btn_restart)) { _, _ ->
                    ThemePrefs.setDynamicColor(requireContext(), isChecked)
                    (requireActivity().application as App).applyDynamicColors()
                    restartApp()
                }
                .setNegativeButton(getString(R.string.btn_cancel)) { _, _ ->
                    switch.setOnCheckedChangeListener(null)
                    switch.isChecked = !isChecked
                    setupDynamicColorSwitch(view)
                }
                .show()
        }
    }

    private fun restartApp() {
        val intent = requireActivity().packageManager.getLaunchIntentForPackage(requireActivity().packageName)!!
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        requireActivity().finish()
    }
}
