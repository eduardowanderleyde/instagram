import * as FilePond from "filepond";
import FilePondPluginImagePreview from "filepond-plugin-image-preview";
import FilePondPluginFileValidateType from "filepond-plugin-file-validate-type";

FilePond.registerPlugin(FilePondPluginImagePreview, FilePondPluginFileValidateType);

// Transforma os inputs de upload de post (class="filepond") em FilePond.
document.addEventListener("turbo:load", () => {
  document.querySelectorAll("input[type=file].filepond").forEach((input) => {
    FilePond.create(input, {
      credits: false,
      storeAsFile: true,
      allowMultiple: true,
      allowReorder: true,
      acceptedFileTypes: ["image/*"],
      labelIdle: 'Drag photos here or <span class="filepond--label-action">select from computer</span>',
    });
  });
});
