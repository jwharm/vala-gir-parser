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

using Gee;

/**
 * Provides a view over a list of Nodes, that only contains elements of a
 * specific type.
 * 
 * Modifications to a FilteredNodeList will be applied to the backing list.
 * If the backing list is read-only, then the view is read-only as well.
 * 
 * Because the view does not maintain any additional state, most operations
 * traverse the backing list from the start, looking for elements with the
 * required type. As a result, most operations have linear time complexity.
 * 
 * The view relies on the backing list to perform out-of-bounds checks.
 */
public class FilteredNodeList<G> : AbstractBidirList<G> {
    private Gee.List<Gir.Node> data;
    private GLib.Type type;
    
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
     * Returns whether the backing list (and therefore, this list) is read-only.
     */
    public override bool read_only {
        get {
            return data.read_only;
        }
    }
    
    /**
     * Create a new FilteredNodeList for the specified type. The type must be
     * a (subclass of) Gir.Node.
     */
    public FilteredNodeList (owned Gee.List<Gir.Node> backing_list,
                             GLib.Type filter_type) {
        this.data = backing_list;
        this.type = filter_type;
        assert (filter_type.is_a (typeof (Gir.Node)));
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool foreach (ForallFunc<G> f) {
        var iter = iterator ();
        while (iter.next ()) {
            if (! f (iter.get ())) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * {@inheritDoc}
     */
    public override Gee.Iterator<G> iterator () {
        return new Iterator<G> (data, type);
    }
    
    /**
     * {@inheritDoc}
     */
    public override ListIterator<G> list_iterator () {
        return new Iterator<G> (data, type);
    }
    
    /**
     * {@inheritDoc}
     */
    public override BidirListIterator<G> bidir_list_iterator () {
        return new Iterator<G> (data, type);
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool contains (G item) {
        return data.contains ((Gir.Node) item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override int index_of (G item) {
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
    public override G get (int index) {
        var iter = iterator ();
        for (int i = -1; i < index; i++) {
            iter.next ();
        }
        
        return iter.get ();
    }
    
    /**
     * {@inheritDoc}
     */
    public override void set (int index, G item) {
        var iter = (Iterator<G>) iterator ();
        for (int i = -1; i < index; i++) {
            iter.next ();
        }
        
        iter.set (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool add (G item) {
        return data.add ((Gir.Node) item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override void insert (int index, G item) {
        var iter = (Iterator<G>) iterator ();
        for (int i = 0; i < index; i++) {
            iter.next ();
        }
        
        iter.add (item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override bool remove (G item) {
        return data.remove ((Gir.Node) item);
    }
    
    /**
     * {@inheritDoc}
     */
    public override G remove_at (int index) {
        var iter = iterator ();
        for (int i = -1; i < index; i++) {
            iter.next ();
        }
        
        G item = iter.get ();
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
    public override Gee.List<G>? slice (int start, int stop) {
        var slice = new ArrayList<G> ();
        var iter = iterator ();
        int i = 0;
        
        while (i++ < stop) {
            iter.next ();
            if (i >= start) {
                slice.add (iter.get ());
            }
        }
        
        return slice;
    }
    
    /**
     * {@inheritDoc}
     */
    public bool add_all (Collection<G> collection) {
        if (collection.is_empty) {
            return false;
        }
        
        foreach (var item in collection) {
            add (item);
        }
        
        return true;
    }
    
    private class Iterator<G> : Object, Traversable<G>, Gee.Iterator<G>,
                                BidirIterator<G>, ListIterator<G>,
                                BidirListIterator<G> {
        private Gee.List<Gir.Node> data;
        private GLib.Type type;
        private int cursor = -1;
        
        public bool read_only {
            get {
                return data.read_only;
            }
        }
        
        public bool valid {
            get {
                return cursor != -1;
            }
        }
        
        public Iterator (Gee.List<Gir.Node> backing_list,
                         GLib.Type filter_type) {
            this.data = backing_list;
            this.type = filter_type;
        }
        
        public Iterator.from_iterator (Iterator<G> iter) {
            this.data = iter.data;
            this.type = iter.type;
            this.cursor = iter.cursor;
        }
        
        private int previous_index_from (int current) {
            for (int i = current - 1; i > 0; i--) {
                if (data[i].get_type ().is_a (type)) {
                    return i;
                }
            }
            
            return -1;
        }
        
        private int next_index_from (int current) {
            for (int i = current + 1; i < data.size; i++) {
                if (data[i].get_type ().is_a (type)) {
                    return i;
                }
            }
            
            return -1;
        }
        
        public bool next () {
            cursor = next_index_from (cursor);
            return valid;
        }
        
        public bool has_next () {
            return next_index_from (cursor) != -1;
        }
        
        public bool first () {
            cursor = -1;
            return next ();
        }
        
        public new G get () {
            return (G) data[cursor];
        }
        
        public void remove () {
            data.remove_at (cursor);
            previous ();
        }
        
        public bool previous () {
            cursor = previous_index_from (cursor);
            return valid;
        }
        
        public bool has_previous () {
            return previous_index_from (cursor) != -1;
        }
        
        public bool last () {
            cursor = data.size + 1;
            return previous ();
        }
        
        public new void set (G item) {
            data[cursor] = (Gir.Node) item;
        }
        
        public void insert (G item) {
            data.insert (cursor, (Gir.Node) item);
            cursor++;
        }
        
        public void add (G item) {
            cursor++;
            data.insert (cursor, (Gir.Node) item);
        }
        
        public int index () {
            int pos = 0;
            for (int i = -2; i != -1 && i < cursor; i = next_index_from (i)) {
                pos++;
            }
            
            return pos;
        }
        
        public bool foreach (ForallFunc<G> f) {
            while (next ()) {
                if (! f (get ())) {
                    return false;
                }
            }
            
            return true;
        }
        
        public Gee.Iterator<G>[] tee (uint forks) {
            if (forks == 0) {
                return new Gee.Iterator<G>[0];
            }
            
            Gee.Iterator<G>[] result = new Gee.Iterator<G>[forks];
            result[0] = this;
            for (uint i = 1; i < forks; i++) {
                result[i] = new Iterator<G>.from_iterator (this);
            }
            
            return result;
        }
    }
}

