/* vala-gir-parser
 * Copyright (C) 2024 Jan-Willem Harmannij
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 */

using Vala;

 /**
 * Provides a view over a list of Nodes, that only contains elements with a
 * specific tag.
 * 
 * Modifications to a FilteredNodeList will be applied to the backing list.
 * If the backing list is read-only, then the view is read-only as well.
 * 
 * Because the view does not maintain any additional state, most operations
 * traverse the backing list from the start, looking for elements with the
 * required tag. As a result, most operations have linear time complexity.
 * 
 * The view relies on the backing list to perform out-of-bounds checks.
 */
public class FilteredNodeList : Vala.List<Gir.Node> {
    private Vala.List<Gir.Node> data;
    private string tag;
    
    /**
     * Counts the number of elements with the specified type that exist in the
     * backing list.
     */
    public override int size {
        get {
            var iter = iterator ();
            int i = 0;
            while (iter.next ()) {
                i++;
            }
            
            return i;
        }
    }
    
    /**
     * Create a new FilteredNodeList for the specified tag.
     */
    public FilteredNodeList (owned Vala.List<Gir.Node> backing_list,
                             string tag) {
        this.data = backing_list;
        this.tag = tag;
    }

    /**
     * {@inheritDoc}
     */
     public override Type get_element_type () {
        return typeof (Gir.Node);
    }
    
    /**
     * {@inheritDoc}
     */
    public override Iterator<Gir.Node> iterator () {
        return new NodeListIterator (data, tag);
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool contains (Gir.Node item) {
        return data.contains (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override int index_of (Gir.Node item) {
        int index = -1;
        var iter = iterator ();
        while (iter.next ()) {
            if (iter.get () == item) {
                return index;
            }
            
            index++;
        }
        
        return index;
    }
    
    /**
     * {@inheritDoc}
     */
    public override Gir.Node get (int index) {
        var iter = iterator ();
        for (int i = -1; i < index; i++) {
            iter.next ();
        }
        
        return iter.get ();
    }
    
    /**
     * {@inheritDoc}
     */
    public override void set (int index, Gir.Node item) {
        var iter = (NodeListIterator) iterator ();
        for (int i = -1; i < index; i++) {
            iter.next ();
        }
        
        iter.set (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool add (Gir.Node item) {
        return data.add (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override void insert (int index, Gir.Node item) {
        var iter = (NodeListIterator) iterator ();
        for (int i = 0; i < index; i++) {
            iter.next ();
        }
        
        iter.add (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool remove (Gir.Node item) {
        return data.remove (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override Gir.Node remove_at (int index) {
        var iter = iterator ();
        for (int i = -1; i < index; i++) {
            iter.next ();
        }
        
        Gir.Node item = iter.get ();
        iter.remove ();
        return item;
    }
    
    /**
     * {@inheritDoc}
     */
    public override void clear () {
        var iter = iterator ();
        while (iter.next ()) {
            iter.remove();
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool add_all (Collection<Gir.Node> collection) {
        if (collection.is_empty) {
            return false;
        }
        
        foreach (var item in collection) {
            add (item);
        }
        
        return true;
    }
    
    private class NodeListIterator : Vala.Iterator<Gir.Node> {
        private Vala.List<Gir.Node> data;
        private string tag;
        private int cursor = -1;
        
        public override bool valid {
            get {
                return cursor != -1;
            }
        }
        
        public NodeListIterator (Vala.List<Gir.Node> backing_list, string tag) {
            this.data = backing_list;
            this.tag = tag;
        }
        
        private int previous_index_from (int current) {
            for (int i = current - 1; i > 0; i--) {
                if (data[i].tag == tag) {
                    return i;
                }
            }
            
            return -1;
        }
        
        private int next_index_from (int current) {
            for (int i = current + 1; i < data.size; i++) {
                if (data[i].tag == tag) {
                    return i;
                }
            }
            
            return -1;
        }
        
        public override bool next () {
            cursor = next_index_from (cursor);
            return valid;
        }
        
        public override bool has_next () {
            return next_index_from (cursor) != -1;
        }
        
        public override Gir.Node get () {
            return data[cursor];
        }
        
        public override void remove () {
            data.remove_at (cursor);
            previous ();
        }
        
        public bool previous () {
            cursor = previous_index_from (cursor);
            return valid;
        }
        
        public new void set (Gir.Node item) {
            data[cursor] = item;
        }
        
        public void add (Gir.Node item) {
            cursor++;
            data.insert (cursor, item);
        }
    }
}

