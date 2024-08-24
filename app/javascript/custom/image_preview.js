document.addEventListener("turbo:load", function() {
  const fileInput = document.querySelector('.field');
  const previewImage = document.getElementById('image-preview');
  const dropzone = document.querySelector('#dropzone');

  fileInput.addEventListener('change', function(event) {
    const file = event.target.files[0];

    if (file && (file.type === 'image/png' || file.type === 'image/jpeg')) {
      const reader = new FileReader();

      reader.onload = function(e) {
        previewImage.src = e.target.result;
        previewImage.classList.remove('hidden');
        dropzone.classList.add('hidden');
      };

      reader.readAsDataURL(file);
    } else {
      previewImage.src = '#';
      previewImage.classList.add('hidden');
    }
  });
});
