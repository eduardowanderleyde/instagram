import * as FilePond from "filepond";

// Import the plugins
import FilePondPluginImagePreview from "filepond-plugin-image-preview";
import FilePondPluginFileValidateType from "filepond-plugin-file-validate-type";

// Register the plugins 
document.addEventListener('turbo:load', loadFilePond);

  function loadFilePond(){
  FilePond.registerPlugin(
    FilePondPluginImagePreview,
    FilePondPluginFileValidateType
    );

  // Get a reference to the file input element
  const inputElement = document.querySelector('#post-images');

  // Create a FilePond instance
  const pond = FilePond.create(inputElement, {
    credits: {},
    storeAsFile: true,
    allowMultiple: true,
    allowReorder: true,
    acceptedFileTypes: ['image/*'],
  });
}