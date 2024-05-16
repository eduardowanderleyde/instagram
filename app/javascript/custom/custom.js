import * as FilePond from "filepond";

// Import the plugins
import FilePondPluginImagePreview from "filepond-plugin-image-preview";
import FilePondPluginFileValidateType from "filepond-plugin-file-validate-type";

// Register the plugins
FilePond.registerPlugin(
  FilePondPluginImagePreview,
  FilePondPluginImageType
  );

// Get a reference to the file input element
const inputElement = document.querySelector('#post-images');

// Create a FilePond instance
const pond = FilePond.create(inputElement, {
  credits: false,
  allowMultiple: true,
  allowReorder: true,
  acceptedFileTypes: ['image/*'],
});