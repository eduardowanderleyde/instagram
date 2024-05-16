import * as FilePond from "filepond";

const inputElement = document.querySelector('#post-images');

const pond = FilePond.create(inputElement, {
  credits: false,
  allowMultiple: true,
  allowReorder: true,
});