import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {

  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(
            color:
                Colors.black12,

            blurRadius: 8,

            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Material(

        color: Colors.transparent,

        child: InkWell(

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          onTap: onTap,

          child: Padding(

            padding:
                const EdgeInsets.all(
              18,
            ),

            child: Row(

              children: [

                Container(

                  width: 60,
                  height: 60,

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.green
                            .withOpacity(
                      0.12,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                  ),

                  child: Center(
                    child: icon,
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(

                  child: Text(

                    title,

                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(

                  Icons
                      .arrow_forward_ios,

                  color:
                      Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}