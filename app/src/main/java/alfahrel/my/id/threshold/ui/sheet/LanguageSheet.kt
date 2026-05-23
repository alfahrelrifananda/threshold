package alfahrel.my.id.threshold.ui.sheet

import alfahrel.my.id.threshold.R
import alfahrel.my.id.threshold.util.LanguagePrefs
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.button.MaterialButton
import com.google.android.material.button.MaterialButtonToggleGroup
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class LanguageSheet : BottomSheetDialogFragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View = inflater.inflate(R.layout.sheet_language, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val group = view.findViewById<MaterialButtonToggleGroup>(R.id.btnGroupLanguage)
        val btnEnglish = view.findViewById<MaterialButton>(R.id.btnLangEnglish)
        val btnIndo = view.findViewById<MaterialButton>(R.id.btnLangIndonesian)

        val current = LanguagePrefs.loadLanguage(requireContext())
        group.check(if (current == "in") btnIndo.id else btnEnglish.id)

        group.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (!isChecked) return@addOnButtonCheckedListener
            val langCode = if (checkedId == R.id.btnLangIndonesian) "in" else "en"
            if (langCode == LanguagePrefs.loadLanguage(requireContext())) return@addOnButtonCheckedListener

            MaterialAlertDialogBuilder(requireContext())
                .setTitle(getString(R.string.dialog_change_language))
                .setMessage(getString(R.string.dialog_language_message))
                .setPositiveButton(getString(R.string.btn_restart)) { _, _ ->
                    LanguagePrefs.saveLanguage(requireContext(), langCode)
                    restartApp()
                }
                .setNegativeButton(getString(R.string.btn_cancel)) { _, _ ->
                    val previous = LanguagePrefs.loadLanguage(requireContext())
                    group.check(if (previous == "in") btnIndo.id else btnEnglish.id)
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
