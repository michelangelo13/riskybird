/**
 * Code used to apply a lint rule automatically.
 *
 * This still needs lots of work :(
 *
 *
 *
 *   This file is part of RiskyBird
 *
 *   RiskyBird is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   RiskyBird is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with RiskyBird.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @author Julien Verlaguet
 * @author Alok Menghrajani
 */

module RegexpFixUnreferencedGroup {
  function regexp regexp(regexp re, int id_to_match) {
    List.map(function(e){alternative(e, id_to_match)}, re)
  }

  function alternative alternative(alternative s, int id_to_match) {
    List.map(function(e){do_term(e, id_to_match)}, s)
  }

  function term do_term(term term, int id_to_match) {
    match (term) {
      case {~id, ~atom, ~quantifier, ~greedy}:
        {~id, atom: do_atom(atom, id_to_match), ~quantifier, ~greedy}
      case _: term
    }
  }

  function atom do_atom(atom atom, int id_to_match) {
    match (atom) {
      case {~id, ~group_id, ~group}:
        if (group_id == id_to_match) {
          ncgroup = regexp(group, id_to_match)
          {~ncgroup}
        } else {
          {~id, ~group_id, group:regexp(group, id_to_match)}
        }
      case {~group_ref}:
        if (group_ref >= id_to_match) {
          {group_ref: group_ref-1}
        } else {
          {~group_ref}
        }
      case _: atom
    }
  }
}

module RegexpFixNonOptimalCharacterRange {
  function regexp regexp(regexp re, int character_class_id, character_class new_range) {
    List.map(function(e){alternative(e, character_class_id, new_range)}, re)
  }

  function alternative alternative(alternative s, int character_class_id, character_class new_range) {
    List.map(function(e){do_term(e, character_class_id, new_range)}, s)
  }

  function term do_term(term term, int character_class_id, character_class new_range) {
    match (term) {
      case {~id, ~atom, ~quantifier, ~greedy}:
        {~id, atom: do_atom(atom, character_class_id, new_range), ~quantifier, ~greedy}
      case _: term
    }
  }

  function atom do_atom(atom atom, int character_class_id, character_class new_range) {
    match (atom) {
      case {~id, char_class:_}:
        if (id == character_class_id) {
          {~id, char_class:new_range}
        } else {
          atom;
        }
      case {~id, ~group_id, group:sub_re}:
        {~id, ~group_id, group: regexp(sub_re, character_class_id, new_range)}
      case {ncgroup: sub_re}:
        {ncgroup: regexp(sub_re, character_class_id, new_range)}
      case _: atom
    }
  }
}
