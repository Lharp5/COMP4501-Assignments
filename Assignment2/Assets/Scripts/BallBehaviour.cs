using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallBehaviour : MonoBehaviour {
    public float speed;
    private float direction;
    Rigidbody rb;
    string lastCollision;

	// Use this for initialization
	void Start () {
        rb = GetComponent<Rigidbody>();
        direction = 1;
        lastCollision = null;
	}

    // Before physics
    void FixedUpdate()
    {

        // Want to move around and forward/back but not down.
        Vector3 movement = new Vector3(direction, 0, 0);
        rb.AddForce(movement * speed);
    }

    // Update is called once per frame
    void Update () {
		
	}

    void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.tag != lastCollision && collision.gameObject.tag != "floor")
        {
            lastCollision = collision.gameObject.tag;
            direction = direction == 1 ? -1 : 1;
        }
        
    }
}
