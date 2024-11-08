    //add class="draggable" to each element to be dragged; add fromLTID="" and fromXID="" on each AND/OR fromGenericID=""
    //add class="dragTarget" to each element to be a target; add toLTID="" and toXID="" on eac AND/OR toGenericID=""h
    //on drop, an ajax call is made to the server using to and from LTIDs and XIDs and the genericIDs

    //select draggable items and targets into list
    document.addEventListener(DOMContentLoaded, function(event){
        initializeDrag();
    });





    function initializeDrag(e){
        let dragItems = document.querySelectorAll('.draggable');
        let dropTargets = document.querySelectorAll('.dragTarget');

        dropTargets.forEach(function(dropTarget){
            //add event listeners for each dropTarget
            dropTarget.addEventListener('dragover', onDragOver);
            dropTarget.addEventListener('dragenter', onDragEnter);
            dropTarget.addEventListener('dragleave', onDragLeave);
            dropTarget.addEventListener('drop', onDrop);
        });

        dragItems.forEach(function(dragItem){
            //remove .over class from each draggable item, and give give it the draggable = true attribute so it can be moved
            dragItem.classList.remove('over');
            dragItem.setAttribute('draggable', 'true');

            //add event listners for when a draggable item starts and ends dragging
            dragItem.addEventListener('dragstart', onDragStart);
            dragItem.addEventListener('dragend', onDragEnd);
        });
    };





    function onDragStart(e){
        let dragItems = document.querySelectorAll('.draggable');
        //prevent this item from being dragged into itself
        if (this.classList.contains('dragTarget')){
            this.classList.remove('dragTarget')
            this.classList.add('wasDragTarget');

            //remove event listners so the item ceases to act as a target
            this.removeEventListener('dragover', onDragOver);
            this.removeEventListener('dragenter', onDragEnter);
            this.removeEventListener('dragleave', onDragLeave);
            this.removeEventListener('drop', onDrop);
        };

        //remove outline from previous drags
        dragItems.forEach(function(dragItem){
            dragItem.style.outline = 'none';
        });

        //style current drag
        this.style.opacity = '.4';
        this.style.outline = '1px dotted #666';
        
        //texthtml to send full html element
        if (this.getAttribute('fromLTID') == undefined) {this.setAttribute('fromLTID', 0)}
        if (this.getAttribute('fromXID') == undefined) {this.setAttribute('fromXID', 0)}
        if (this.getAttribute('fromGenericID') == undefined) {this.setAttribute('fromGenericID', 0)}
        if (this.getAttribute('loader') == undefined) {this.setAttribute('loader', 'body')}

        var jsonString = {fromLTIDthis.getAttribute('fromLTID'), fromXIDthis.getAttribute('fromXID'), fromGenericIDthis.getAttribute('fromGenericID'), ecidthis.getAttribute('ecid'), loaderthis.getAttribute('loader'), actthis.getAttribute('act')};
        e.dataTransfer.setData('text', JSON.stringify(jsonString));
    };
    




    function onDragEnd(e){
        //reset element styles
        this.style.opacity = '1';

        //if has class wasDragTarget, add dragTarget and remove wasDragTarget
        if (this.classList.contains('wasDragTarget')){
            this.classList.remove('wasDragTarget');
            this.classList.add('dragTarget');

            add event listeners back in so the item acts as a target
            this.removeEventListener('dragover', onDragOver);
            this.removeEventListener('dragenter', onDragEnter);
            this.removeEventListener('dragleave', onDragLeave);
            this.removeEventListener('drop', onDrop);
        };
    };





    function onDragOver(e){
        //prevent drop event from firing when it shouldn't
        e.preventDefault();
        return false;
    };





    function onDragEnter(e){
        //add .over to dragTarget when it is dragged over
        this.classList.add('over');
    };





    function onDragLeave(e){
        //remove .over class from dragTarget when not hovered over
        this.classList.remove('over');
    };





    function onDrop(e){
        let dropTargets = document.querySelectorAll('.dragTarget');
        //prevent default behavior and prevent propogration from firing onDrop mutliple times
        e.stopPropagation();
        e.stopImmediatePropagation();
        
        //make sure no dropTargets have the .over class anymore
        dropTargets.forEach(function(dropTarget){
            dropTarget.classList.remove('over');
        });
        
        //get to and from entity data and store in variables
        var fromData = JSON.parse(e.dataTransfer.getData('text'));
        if (this.getAttribute('act') == undefined) {this.setAttribute('act', 'dragDrop')};

        fromLTID = fromData['fromLTID'];
        fromXID = fromData['fromXID'];
        fromGenericID = fromData['fromGenericID'];
        toLTID = this.getAttribute('toLTID');
        toXID = this.getAttribute('toXID');
        toGenericID = this.getAttribute('toGenericID');
        loader = fromData['loader'];
        ecid = fromData['ecid'];
        act = this.getAttribute('act');

        //tofrom combo used to identify dragged element vs target... LTIDXID by default, genericID if it is an element without LTIDXID

        ajaxPostDrop();  
        return false;
    };





    function ajaxPostDrop(e){
        if (loader == undefined) {loader = 'body'}
        addLoader(ecid, loader);

        var send_data = {}
        send_data['fromLTID'] = fromLTID;
        send_data['fromXID'] = fromXID;
        send_data['fromGenericID'] = fromGenericID;
        send_data['toLTID'] = toLTID;
        send_data['toXID'] = toXID;
        send_data['toGenericID'] = toGenericID;
        send_data['ecid'] = ecid;
        send_data['loader'] = loader;
        send_data['act'] = act;

        $.ajax({
            type 'POST',
            url document.URL,
            aync true,
            success showResponse,
            datasend_data,
            complete initializeDrag
        });
    };
    