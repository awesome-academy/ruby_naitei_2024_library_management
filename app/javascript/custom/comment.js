document.addEventListener('turbo:load', function() {
    const textArea = document.getElementById('comment_input');
    textArea.addEventListener('keydown', function(event) {
      if (event.key === 'Enter') {
        if (event.shiftKey) {
          // Allow Shift + Enter to insert a line break
          return;
        }

        // Prevent the default Enter key behavior (form submission or newline)
        event.preventDefault();
        // Trigger the form submission
        const form = textArea.closest('form');
        if (form) {
          form.requestSubmit();
          textArea.value = '';
        }
      }
    });
});
