document.addEventListener('turbo:load', function() {
  if (typeof tinymce !== 'undefined') {
    tinymce.remove();
    tinymce.init({
      selector: '.tinymce',
      plugins: 'lists link image table code help wordcount',
      toolbar: 'undo redo | formatselect | bold italic backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | removeformat | help',
      menubar: false,
      height: 300,
    });
  }
});
