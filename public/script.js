/* 
 * funzione per la gestione del mostra/nascondi
 * una qualsiasi div/cosa
 */
function toggle_visibility(id)
{
    var vis = document.getElementById(id);
    if (vis.style.display == 'block')
    {
        vis.style.display = 'none';
    }
    else
    {
        vis.style.display = 'block';
    }
}
