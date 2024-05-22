window.addEventListener('message', (event) => {
    if (event.data.isReady) {
        document.getElementById('title').innerHTML = event.data.text;
        return title.style.display = 'block';
    }
    return title.style.display = 'none';
});