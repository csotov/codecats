import 'package:flutter/material.dart';

import '../engine/blocks.dart';
import '../l10n.dart';
import 'theme.dart';

/// Visual block editor: palette on top, program tree below,
/// live generated-C++ preview at the bottom.
class BlocksEditor extends StatefulWidget {
  const BlocksEditor({
    super.key,
    required this.allowed,
    required this.roots,
    required this.onChanged,
    this.preview = true,
  });

  /// Block ids available in the palette for this level.
  final List<String> allowed;

  /// The program forest (mutated in place).
  final List<BlockNode> roots;

  /// Called whenever the tree changes (params, order, add, delete).
  final VoidCallback onChanged;

  /// Whether to show the generated C++ preview.
  final bool preview;

  @override
  State<BlocksEditor> createState() => _BlocksEditorState();
}

class _BlocksEditorState extends State<BlocksEditor> {
  static const _catColors = {
    'io': Color(0xFF4CC2FF),
    'var': Color(0xFF7C9EFF),
    'ctrl': Color(0xFFFFB74D),
    'array': Color(0xFF4ADE80),
    'misc': Color(0xFF9AA7C7),
  };

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- palette ----------------------------------------------------
        Text(l.t('blocks_palette'),
            style: const TextStyle(color: AppTheme.textLo, fontSize: 12)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final id in widget.allowed)
                if (kBlockDefs[id] != null) _paletteChip(kBlockDefs[id]!),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(l.t('tap_param_hint'),
            style: const TextStyle(
                color: AppTheme.textLo,
                fontSize: 11,
                fontStyle: FontStyle.italic)),
        const Divider(height: 18),
        // ---- program -----------------------------------------------------
        if (widget.roots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(l.t('empty_blocks_msg'),
                  style: const TextStyle(color: AppTheme.textLo)),
            ),
          )
        else
          _BlockList(nodes: widget.roots, depth: 0, onChanged: _changed),
        // ---- generated code preview --------------------------------------
        if (widget.preview) ...[
          const Divider(height: 22),
          Text(l.t('view_code'),
              style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.cardEdge),
            ),
            child: SelectableText(
              blocksToCode(widget.roots),
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.4,
                  color: AppTheme.textHi),
            ),
          ),
        ],
      ],
    );
  }

  Widget _paletteChip(BlockDef def) {
    final l = L.instance;
    final color = _catColors[def.category] ?? AppTheme.textLo;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text('+ ${l.pick(def.labelEs, def.labelEn)}',
            style: const TextStyle(fontSize: 12)),
        backgroundColor: color.withOpacity(0.12),
        side: BorderSide(color: color.withOpacity(0.6)),
        onPressed: () {
          final node = BlockNode(def.id);
          for (final p in def.params) {
            node.params[p.key] = p.defaultValue;
          }
          widget.roots.add(node);
          _changed();
        },
      ),
    );
  }
}

/// Recursive list of block cards.
class _BlockList extends StatelessWidget {
  const _BlockList(
      {required this.nodes, required this.depth, required this.onChanged});

  final List<BlockNode> nodes;
  final int depth;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < nodes.length; i++)
          Padding(
            // Key on the NODE (not the index) so when blocks are moved,
            // the card and its TextFormField state travel WITH the block —
            // otherwise fields show the previous occupant's text.
            key: ObjectKey(nodes[i]),
            padding: EdgeInsets.only(left: depth * 18.0, bottom: 8),
            child: _BlockCard(
              node: nodes[i],
              index: i,
              siblings: nodes,
              depth: depth,
              onChanged: onChanged,
            ),
          ),
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.node,
    required this.index,
    required this.siblings,
    required this.depth,
    required this.onChanged,
  });

  final BlockNode node;
  final int index;
  final List<BlockNode> siblings;
  final int depth;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final def = kBlockDefs[node.defId];
    if (def == null) return const SizedBox.shrink();
    final color = _BlocksEditorState._catColors[def.category] ??
        AppTheme.textLo;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l.pick(def.labelEs, def.labelEn),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
              _iconBtn(Icons.arrow_upward, l.t('move_up'),
                  index > 0
                      ? () {
                          siblings.removeAt(index);
                          siblings.insert(index - 1, node);
                          onChanged();
                        }
                      : null),
              _iconBtn(Icons.arrow_downward, l.t('move_down'),
                  index < siblings.length - 1
                      ? () {
                          siblings.removeAt(index);
                          siblings.insert(index + 1, node);
                          onChanged();
                        }
                      : null),
              _iconBtn(Icons.delete_outline, l.t('delete_block'), () {
                siblings.removeAt(index);
                onChanged();
              }),
            ],
          ),
          if (def.params.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final p in def.params)
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        initialValue: node.params[p.key] ??
                            p.defaultValue,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                        decoration: InputDecoration(
                          labelText: l.pick(p.labelEs, p.labelEn),
                          labelStyle: const TextStyle(fontSize: 10),
                          hintText: p.hint,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                        onChanged: (v) {
                          node.params[p.key] = v;
                          onChanged();
                        },
                      ),
                    ),
                ],
              ),
            ),
          if (def.hasBody) ...[
            const SizedBox(height: 6),
            _BlockList(
                nodes: node.children,
                depth: depth + 1,
                onChanged: onChanged),
            _addInside(node.children, l),
          ],
          if (def.hasElse) ...[
            const SizedBox(height: 6),
            Text(l.pick('Si no / else', 'Else'),
                style: const TextStyle(
                    color: AppTheme.textLo,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            _BlockList(
                nodes: node.elseChildren,
                depth: depth + 1,
                onChanged: onChanged),
            _addInside(node.elseChildren, l),
          ],
        ],
      ),
    );
  }

  Widget _addInside(List<BlockNode> list, L l) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: (depth + 1) * 18.0, top: 2),
        child: _InnerAddMenu(list: list, onChanged: onChanged),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tip, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: AppTheme.textLo,
      tooltip: tip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      onPressed: onTap,
    );
  }
}

/// Popup "add block inside" menu for container bodies.
class _InnerAddMenu extends StatelessWidget {
  const _InnerAddMenu({required this.list, required this.onChanged});
  final List<BlockNode> list;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    // All defs are allowed inside; palette scoping applies at top level.
    return PopupMenuButton<String>(
      onSelected: (id) {
        final def = kBlockDefs[id]!;
        final node = BlockNode(id);
        for (final p in def.params) {
          node.params[p.key] = p.defaultValue;
        }
        list.add(node);
        onChanged();
      },
      itemBuilder: (c) => [
        for (final def in kBlockDefs.values)
          PopupMenuItem(
            value: def.id,
            child: Text(l.pick(def.labelEs, def.labelEn),
                style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.cardEdge.withOpacity(0.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('+ ${l.t('add_block')}',
            style: const TextStyle(fontSize: 11, color: AppTheme.accent)),
      ),
    );
  }
}
